import Foundation

/// Records the app's own HTTP traffic and forwards each request through an internal session.
///
/// Forwarded requests carry a marker property so they are never captured twice.
/// Client callbacks are delivered on the thread that called `startLoading()`, as
/// `URLProtocolClient` requires.
final class SnitchURLProtocol: URLProtocol {
    static let handledKey = "dev.snitch.handled"

    /// The session that performs the real requests. Replaceable in tests.
    static var forwarder = Forwarder(configuration: .default)

    // Set in startLoading, then touched only on the forwarder's serial delegate queue.
    private var entry: NetworkEntry?
    private var responseBody = CappedBody()
    private var startUptime: TimeInterval = 0
    private var finished = false
    private var forwardedTask: URLSessionDataTask?

    // Touched only on the client thread.
    private var clientThread: ClientThread?
    private var stopped = false

    // A challenge the app's session has not answered yet.
    private let challengeLock = NSLock()
    private var pendingChallenge: ChallengeAnswer?

    override class func canInit(with request: URLRequest) -> Bool {
        Snitch.isCapturing && request.isHTTP && !request.isForwardedBySnitch
            && !Snitch.isIgnored(host: request.url?.host)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        clientThread = ClientThread.current()

        // Read the body once so it can be both recorded and forwarded.
        let body = request.readBody()
        let entry = NetworkEntry(
            url: request.url,
            method: request.httpMethod ?? "GET",
            requestHeaders: request.allHTTPHeaderFields ?? [:],
            requestBody: body
        )
        self.entry = entry
        startUptime = ProcessInfo.processInfo.systemUptime
        Snitch.store.insert(entry)
        forwardedTask = Self.forwarder.start(request.forwardedBySnitch(body: body), for: self)
    }

    override func stopLoading() {
        stopped = true
        challengeLock.withLock { pendingChallenge }?.answer(.cancelAuthenticationChallenge, nil)
        forwardedTask?.cancel()
    }

    // MARK: Forwarder callbacks (serial delegate queue)

    func didReceive(_ response: URLResponse) {
        guard !finished else { return }
        if let http = response as? HTTPURLResponse {
            record(http)
        }
        onClient { $0.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed) }
    }

    func didReceive(_ data: Data) {
        guard !finished else { return }
        // Buffered here; the store is updated once at completion so a large
        // download does not publish a new snapshot for every chunk.
        responseBody.append(data)
        onClient { $0.urlProtocol(self, didLoad: data) }
    }

    func willRedirect(_ response: HTTPURLResponse, to newRequest: URLRequest) {
        guard !finished else { return }
        record(response)
        complete(error: nil)

        // The redirected request goes back through the app's own session, where it
        // is captured as its own entry.
        let redirect = newRequest.withoutSnitchMarker()
        onClient {
            $0.urlProtocol(self, wasRedirectedTo: redirect, redirectResponse: response)
            $0.urlProtocol(self, didFailWithError: CocoaError(.userCancelled))
        }
    }

    /// Passes a challenge to the app's session. Its delegate's answer comes back
    /// through a ``ChallengeAnswer``.
    func didReceive(
        _ challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let answer = ChallengeAnswer(completionHandler)
        challengeLock.withLock { pendingChallenge = answer }
        let forwarded = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: answer)
        clientThread?.perform { [self] in
            guard !stopped, let client else {
                return answer.answer(.cancelAuthenticationChallenge, nil)
            }
            client.urlProtocol(self, didReceive: forwarded)
        }
    }

    func didComplete(error: Error?) {
        guard !finished else { return }
        complete(error: error)
        onClient { client in
            if let error {
                client.urlProtocol(self, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(self)
            }
        }
    }

    // MARK: Recording

    private func complete(error: Error?) {
        finished = true
        let duration = ProcessInfo.processInfo.systemUptime - startUptime
        let body = responseBody
        record {
            $0.responseBody = body.data.isEmpty ? nil : body.data
            $0.responseBodySize = body.totalSize
            $0.error = error.map(Self.describe)
            $0.duration = duration
        }
    }

    private func record(_ response: HTTPURLResponse) {
        record {
            $0.statusCode = response.statusCode
            $0.responseHeaders = response.stringHeaders
        }
    }

    private func record(_ change: (inout NetworkEntry) -> Void) {
        guard var entry else { return }
        change(&entry)
        self.entry = entry
        Snitch.store.update(entry)
    }

    /// The error's message plus its domain and code, such as `NSURLErrorDomain -1200`,
    /// so a TLS or connection failure can be told apart at a glance.
    static func describe(_ error: Error) -> String {
        let error = error as NSError
        return "\(error.localizedDescription) (\(error.domain) \(error.code))"
    }

    /// Runs `body` on the client thread unless loading has been stopped.
    private func onClient(_ body: @escaping (URLProtocolClient) -> Void) {
        clientThread?.perform { [self] in
            guard !stopped, let client else { return }
            body(client)
        }
    }
}

