import Foundation

/// Records the app's own HTTP traffic and forwards each request through an internal session.
///
/// Forwarded requests carry a marker property so they are never captured twice.
/// Client callbacks are delivered on the thread that called `startLoading()`, as
/// `URLProtocolClient` requires.
final class TapwireURLProtocol: URLProtocol {
    static let handledKey = "dev.tapwire.handled"

    /// The session that performs the real requests. Replaceable in tests.
    static var forwarder = Forwarder(configuration: .default)

    // Set in startLoading, then touched only on the forwarder's serial delegate queue.
    private var entry: NetworkEntry?
    private var responseBody = Data()
    private var responseBodySize = 0
    private var startUptime: TimeInterval = 0
    private var finished = false
    private var forwardedTask: URLSessionDataTask?

    // Touched only on the client thread.
    private var clientRunLoop: CFRunLoop?
    private var clientModes: [CFString] = []
    private var stopped = false

    override class func canInit(with request: URLRequest) -> Bool {
        guard Tapwire.isCapturing,
              let scheme = request.url?.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              property(forKey: handledKey, in: request) == nil
        else { return false }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let runLoop = CFRunLoopGetCurrent()
        clientRunLoop = runLoop
        clientModes = [CFRunLoopMode.defaultMode.rawValue]
        if let mode = CFRunLoopCopyCurrentMode(runLoop), mode != .defaultMode {
            clientModes.append(mode.rawValue)
        }

        // URLSession often hands protocols a body stream instead of `httpBody`.
        // Read it once so it can be both recorded and forwarded.
        let body = request.httpBody ?? request.httpBodyStream.map(Self.readAll)
        let forwarded = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        if let body, request.httpBody == nil {
            forwarded.httpBody = body
        }
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: forwarded)

        let entry = NetworkEntry(
            url: request.url,
            method: request.httpMethod ?? "GET",
            requestHeaders: request.allHTTPHeaderFields ?? [:],
            requestBody: body
        )
        self.entry = entry
        startUptime = ProcessInfo.processInfo.systemUptime
        Tapwire.store.insert(entry)
        forwardedTask = Self.forwarder.start(forwarded as URLRequest, for: self)
    }

    override func stopLoading() {
        stopped = true
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
        // Buffer locally; the store is updated once at completion so a large
        // download does not publish a new snapshot for every chunk.
        let room = NetworkEntry.maxStoredBodySize - responseBody.count
        if room > 0 {
            responseBody.append(data.prefix(room))
        }
        responseBodySize += data.count
        onClient { $0.urlProtocol(self, didLoad: data) }
    }

    func willRedirect(_ response: HTTPURLResponse, to newRequest: URLRequest) {
        guard !finished else { return }
        record(response)
        complete(error: nil)

        // The redirected request goes back through the app's own session, so it
        // must not carry the marker; it is then captured as its own entry.
        let redirect = (newRequest as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.removeProperty(forKey: Self.handledKey, in: redirect)
        onClient {
            $0.urlProtocol(self, wasRedirectedTo: redirect as URLRequest, redirectResponse: response)
            $0.urlProtocol(self, didFailWithError: CocoaError(.userCancelled))
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

    // MARK: Helpers

    private func complete(error: Error?) {
        finished = true
        let duration = ProcessInfo.processInfo.systemUptime - startUptime
        record {
            $0.responseBody = self.responseBody.isEmpty ? nil : self.responseBody
            $0.responseBodySize = self.responseBodySize
            $0.error = error?.localizedDescription
            $0.duration = duration
        }
    }

    private func record(_ response: HTTPURLResponse) {
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            headers["\(key)"] = "\(value)"
        }
        record {
            $0.statusCode = response.statusCode
            $0.responseHeaders = headers
        }
    }

    private func record(_ change: (inout NetworkEntry) -> Void) {
        guard var entry else { return }
        change(&entry)
        self.entry = entry
        Tapwire.store.update(entry)
    }

    /// Runs `body` on the client thread unless loading has been stopped.
    private func onClient(_ body: @escaping (URLProtocolClient) -> Void) {
        guard let runLoop = clientRunLoop else { return }
        CFRunLoopPerformBlock(runLoop, clientModes as CFArray) { [self] in
            guard !stopped, let client else { return }
            body(client)
        }
        CFRunLoopWakeUp(runLoop)
    }

    static func readAll(_ stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while true {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}

/// One shared internal session that performs forwarded requests and routes its
/// delegate callbacks back to the protocol instance that owns each task.
final class Forwarder: NSObject, URLSessionDataDelegate {
    private let lock = NSLock()
    private var owners: [Int: TapwireURLProtocol] = [:]
    private var session: URLSession!

    init(configuration: URLSessionConfiguration) {
        super.init()
        let queue = OperationQueue()
        queue.name = "dev.tapwire.forwarder"
        queue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }

    func start(_ request: URLRequest, for owner: TapwireURLProtocol) -> URLSessionDataTask {
        let task = session.dataTask(with: request)
        lock.withLock { owners[task.taskIdentifier] = owner }
        task.resume()
        return task
    }

    private func owner(of task: URLSessionTask) -> TapwireURLProtocol? {
        lock.withLock { owners[task.taskIdentifier] }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        owner(of: dataTask)?.didReceive(response)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        owner(of: dataTask)?.didReceive(data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        owner(of: task)?.willRedirect(response, to: request)
        task.cancel()
        completionHandler(nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let owner = lock.withLock { owners.removeValue(forKey: task.taskIdentifier) }
        owner?.didComplete(error: error)
    }
}
