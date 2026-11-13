//
//  StubURLProtocol.swift
//  SnitchTests
//
//  Created by BOniani on 04/11/2026.
//

import Foundation
@testable import Snitch

final class StubURLProtocol: URLProtocol {
    enum Reply {
        case success(status: Int, headers: [String: String] = [:], body: Data = Data())
        case redirect(to: URL, status: Int = 302)
        case failure(URLError.Code)
        case challenge(method: String = NSURLAuthenticationMethodHTTPBasic)
        case hang
    }

    private static let lock = NSLock()
    private static var _handler: (URLRequest) -> Reply = { _ in .success(status: 200) }
    private static var _receivedBodies: [Data] = []

    static var handler: (URLRequest) -> Reply {
        get { lock.withLock { _handler } }
        set { lock.withLock { _handler = newValue } }
    }

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
        if let body = request.httpBody ?? request.httpBodyStream?.readAll() {
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
        case let .challenge(method):
            let space = URLProtectionSpace(
                host: url.host ?? "", port: 443, protocol: "https",
                realm: nil, authenticationMethod: method
            )
            let challenge = URLAuthenticationChallenge(
                protectionSpace: space, proposedCredential: nil, previousFailureCount: 0,
                failureResponse: nil, error: nil, sender: self
            )
            client?.urlProtocol(self, didReceive: challenge)
        case .hang:
            break
        }
    }

    private func reply(_ answer: String) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(answer.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

extension StubURLProtocol: URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        reply("credential:\(credential.user ?? "")")
    }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        reply("none")
    }

    func cancel(_ challenge: URLAuthenticationChallenge) {
        client?.urlProtocol(self, didFailWithError: URLError(.userCancelledAuthentication))
    }

    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        reply("default")
    }

    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        reply("rejected")
    }
}
