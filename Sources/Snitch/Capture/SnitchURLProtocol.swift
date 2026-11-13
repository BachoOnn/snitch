//
//  SnitchURLProtocol.swift
//  Snitch
//
//  Created by BOniani on 04/11/2026.
//

import Foundation

/// Not final: SessionProtocols subclasses it for each installed configuration.
class SnitchURLProtocol: URLProtocol {
    static let handledKey = "dev.snitch.handled"

    static var forwarder = Forwarder(configuration: .default)

    // Touched only on the forwarder's serial delegate queue.
    var entry: NetworkEntry?
    var responseBody = CappedBody()
    var startUptime: TimeInterval = 0
    var finished = false
    var forwardedTask: URLSessionDataTask?

    // Touched only on the client thread.
    var clientThread: ClientThread?
    var stopped = false

    let challengeLock = NSLock()
    var pendingChallenge: ChallengeAnswer?

    override class func canInit(with request: URLRequest) -> Bool {
        Snitch.isCapturing && request.isHTTP && !request.isForwardedBySnitch
            && !Snitch.isIgnored(host: request.url?.host)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        clientThread = ClientThread.current()

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
        let forwarder = SessionProtocols.forwarder(for: object_getClass(self) ?? SnitchURLProtocol.self) ?? SnitchURLProtocol.forwarder
        forwardedTask = forwarder.start(request.forwardedBySnitch(body: body), for: self)
    }

    override func stopLoading() {
        stopped = true
        challengeLock.withLock { pendingChallenge }?.answer(.cancelAuthenticationChallenge, nil)
        forwardedTask?.cancel()
    }

    /// Runs `body` on the client thread unless loading has been stopped.
    func onClient(_ body: @escaping (URLProtocolClient) -> Void) {
        clientThread?.perform { [self] in
            guard !stopped, let client else { return }
            body(client)
        }
    }

    /// Applies `change` to the recorded entry and republishes it.
    func record(_ change: (inout NetworkEntry) -> Void) {
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
}
