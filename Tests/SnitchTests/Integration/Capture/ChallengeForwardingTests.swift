//
//  ChallengeForwardingTests.swift
//  SnitchTests
//
//  Created by BOniani on 13/11/2026.
//

import Foundation
import Testing
@testable import Snitch

extension CaptureTests {
    @Test func forwardsChallengeToTheAppsDelegate() async throws {
        StubURLProtocol.handler = { _ in .challenge() }
        let delegate = ChallengeAnswerer(.useCredential, URLCredential(user: "ana", password: "x", persistence: .none))

        let (data, _) = try await session.data(from: Self.base, delegate: delegate)
        #expect(String(decoding: data, as: UTF8.self) == "credential:ana", "the app's answer reaches the server")
        #expect(delegate.methods == [NSURLAuthenticationMethodHTTPBasic])
        #expect(try await completed(1).first?.statusCode == 200)
    }

    @Test func forwardsSessionWideChallengeToSessionDelegate() async throws {
        StubURLProtocol.handler = { _ in .challenge(method: NSURLAuthenticationMethodClientCertificate) }
        let delegate = SessionChallengeAnswerer()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        Snitch.install(in: configuration)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        defer { session.invalidateAndCancel() }

        let (data, _) = try await session.data(from: Self.base)
        #expect(String(decoding: data, as: UTF8.self) == "credential:pinned")
        #expect(delegate.calls == 1)
    }

    @Test func challengeUsesDefaultHandlingWithoutADelegate() async throws {
        StubURLProtocol.handler = { _ in .challenge() }
        let (data, _) = try await session.data(from: Self.base)
        #expect(String(decoding: data, as: UTF8.self) == "default")
    }

    @Test func appCanRejectAChallenge() async throws {
        StubURLProtocol.handler = { _ in .challenge() }
        let delegate = ChallengeAnswerer(.cancelAuthenticationChallenge)
        await #expect(throws: URLError.self) {
            _ = try await self.session.data(from: Self.base, delegate: delegate)
        }
        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == nil)
        #expect(entry.error != nil)
    }
}

private final class ChallengeAnswerer: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let disposition: URLSession.AuthChallengeDisposition
    private let credential: URLCredential?
    private let lock = NSLock()
    private var _methods: [String] = []

    var methods: [String] { lock.withLock { _methods } }

    init(_ disposition: URLSession.AuthChallengeDisposition, _ credential: URLCredential? = nil) {
        self.disposition = disposition
        self.credential = credential
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        lock.withLock { _methods.append(challenge.protectionSpace.authenticationMethod) }
        completionHandler(disposition, credential)
    }
}

private final class SessionChallengeAnswerer: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var _calls = 0
    var calls: Int { lock.withLock { _calls } }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        lock.withLock { _calls += 1 }
        completionHandler(.useCredential, URLCredential(user: "pinned", password: "", persistence: .none))
    }
}
