import Foundation
@testable import Tapwire

/// Serves canned replies in place of the network, so tests never leave the process.
final class StubURLProtocol: URLProtocol {
    enum Reply {
        case success(status: Int, headers: [String: String] = [:], body: Data = Data())
        case redirect(to: URL, status: Int = 302)
        case failure(URLError.Code)
        case hang
    }

    private static let lock = NSLock()
    private static var _handler: (URLRequest) -> Reply = { _ in .success(status: 200) }
    private static var _receivedBodies: [Data] = []

    /// Decides the reply for each request.
    static var handler: (URLRequest) -> Reply {
        get { lock.withLock { _handler } }
        set { lock.withLock { _handler = newValue } }
    }

    /// Bodies of all requests the stub has received.
    static var receivedBodies: [Data] {
        lock.withLock { _receivedBodies }
    }

    static func reset() {
        lock.withLock {
            _handler = { _ in .success(status: 200) }
            _receivedBodies = []
        }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let body = request.httpBody ?? request.httpBodyStream.map(TapwireURLProtocol.readAll) {
            Self.lock.withLock { Self._receivedBodies.append(body) }
        }
        let url = request.url!
        switch Self.handler(request) {
        case let .success(status, headers, body):
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        case let .redirect(target, status):
            let response = HTTPURLResponse(
                url: url, statusCode: status, httpVersion: "HTTP/1.1",
                headerFields: ["Location": target.absoluteString]
            )!
            client?.urlProtocol(self, wasRedirectedTo: URLRequest(url: target), redirectResponse: response)
        case let .failure(code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        case .hang:
            break
        }
    }

    override func stopLoading() {}
}
