//
//  CaptureTests.swift
//  SnitchTests
//
//  Created by BOniani on 04/11/2026.
//

import Foundation
import Testing
@testable import Snitch

/// Shares global state (Snitch.store, protocol registration, the stub), so tests run one at a time.
@Suite(.serialized)
final class CaptureTests {
    static let base = URL(string: "https://api.snitch.test")!
    let session: URLSession

    private static let forwarder: Void = {
        let forwarding = URLSessionConfiguration.ephemeral
        forwarding.protocolClasses = [StubURLProtocol.self]
        SnitchURLProtocol.forwarder = Forwarder(configuration: forwarding)
    }()

    // Installed once: each installed configuration gets its own protocol class.
    private static let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        Snitch.install(in: configuration)
        return configuration
    }()

    init() {
        Self.forwarder
        StubURLProtocol.reset()
        Snitch.store.clear()
        Snitch.ignoredHosts = []
        Snitch.start()
        session = URLSession(configuration: Self.configuration)
    }

    deinit {
        session.invalidateAndCancel()
        Snitch.stop()
        Snitch.ignoredHosts = []
    }

    func completed(_ count: Int, sourceLocation: SourceLocation = #_sourceLocation) async throws -> [NetworkEntry] {
        for _ in 0..<300 {
            let done = Snitch.store.entries.filter(\.isComplete)
            if done.count >= count { return done }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        Issue.record("Timed out waiting for \(count) entries", sourceLocation: sourceLocation)
        return Snitch.store.entries
    }

    @Test(arguments: [
        ("https://api.snitch.test", true),
        ("http://api.snitch.test", true),
        ("ftp://api.snitch.test", false),
        ("file:///tmp/x", false),
    ])
    func canInitByScheme(url: String, expected: Bool) throws {
        let request = URLRequest(url: try #require(URL(string: url)))
        #expect(SnitchURLProtocol.canInit(with: request) == expected)
    }

    @Test func ignoresForwardedRequests() {
        let marked = NSMutableURLRequest(url: Self.base)
        URLProtocol.setProperty(true, forKey: SnitchURLProtocol.handledKey, in: marked)
        #expect(!SnitchURLProtocol.canInit(with: marked as URLRequest), "forwarded requests must not loop")
    }

    @Test(arguments: [
        ("https://appsflyersdk.com/a", false),
        ("https://rexiop.skadsdkless.APPSFLYERSDK.com/a", false),
        ("https://notappsflyersdk.com/a", true),
        ("https://api.snitch.test/a", true),
    ])
    func ignoredHostsAndTheirSubdomainsAreSkipped(url: String, captured: Bool) throws {
        Snitch.ignoredHosts = [".AppsFlyerSDK.com"]
        let request = URLRequest(url: try #require(URL(string: url)))
        #expect(SnitchURLProtocol.canInit(with: request) == captured)
    }

    @Test func ignoredRequestsStillLoadAndAreNotRecorded() async throws {
        Snitch.ignoredHosts = ["snitch.test"]
        StubURLProtocol.handler = { _ in .success(status: 200, headers: [:], body: Data("ok".utf8)) }
        let (data, _) = try await session.data(from: Self.base)
        #expect(data == Data("ok".utf8))
        #expect(Snitch.store.entries.isEmpty)
    }

    @Test func capturesTheSharedSessionByDefault() async throws {
        #expect(Snitch.isCapturingSharedSession)
        StubURLProtocol.handler = { _ in .success(status: 200, headers: [:], body: Data()) }
        _ = try await URLSession.shared.data(from: Self.base)
        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == 200)
    }

    @Test func canLeaveTheSharedSessionAlone() async throws {
        Snitch.stop()
        Snitch.start(showsButton: false, opensOnShake: false, capturesSharedSession: false)
        #expect(!Snitch.isCapturingSharedSession)

        StubURLProtocol.handler = { _ in .success(status: 204, headers: [:], body: Data()) }
        _ = try await session.data(from: Self.base)
        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == 204)
    }

    @Test func ignoresRequestsWhenStopped() {
        Snitch.stop()
        #expect(!SnitchURLProtocol.canInit(with: URLRequest(url: Self.base)))
    }

    @Test func capturesRequestAndResponse() async throws {
        let payload = Data(#"{"name":"tap"}"#.utf8)
        StubURLProtocol.handler = { _ in
            .success(status: 201, headers: ["Content-Type": "application/json"], body: Data("ok".utf8))
        }
        var request = URLRequest(url: Self.base.appendingPathComponent("users"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload

        let (data, response) = try await session.data(for: request)
        #expect(data == Data("ok".utf8))
        #expect((response as? HTTPURLResponse)?.statusCode == 201)
        #expect(StubURLProtocol.receivedBodies == [payload], "body must be forwarded once")

        let entry = try #require(try await completed(1).first)
        #expect(entry.url == request.url)
        #expect(entry.method == "POST")
        #expect(entry.requestHeaders["Content-Type"] == "application/json")
        #expect(entry.requestBody == payload)
        #expect(entry.requestBodySize == payload.count)
        #expect(entry.statusCode == 201)
        #expect(entry.responseHeaders["Content-Type"] == "application/json")
        #expect(entry.responseBody == Data("ok".utf8))
        #expect(entry.responseBodySize == 2)
        #expect(entry.error == nil)
        #expect((entry.duration ?? -1) >= 0)
    }

    @Test func truncatesLargeResponseButDeliversAll() async throws {
        let body = Data(repeating: 7, count: NetworkEntry.maxStoredBodySize + 10)
        StubURLProtocol.handler = { _ in .success(status: 200, body: body) }

        let (data, _) = try await session.data(from: Self.base)
        #expect(data == body, "the app always receives the full body")

        let entry = try #require(try await completed(1).first)
        #expect(entry.responseBody?.count == NetworkEntry.maxStoredBodySize)
        #expect(entry.responseBodySize == body.count)
    }

    @Test func recordsErrors() async throws {
        StubURLProtocol.handler = { _ in .failure(.notConnectedToInternet) }
        let error = await #expect(throws: URLError.self) {
            _ = try await self.session.data(from: Self.base)
        }
        #expect(error?.code == .notConnectedToInternet)

        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == nil)
        #expect(entry.error != nil)
    }

    @Test func followsRedirects() async throws {
        let old = Self.base.appendingPathComponent("old")
        let new = Self.base.appendingPathComponent("new")
        StubURLProtocol.handler = { request in
            request.url == old ? .redirect(to: new) : .success(status: 200, body: Data("moved".utf8))
        }

        let (data, response) = try await session.data(from: old)
        #expect(data == Data("moved".utf8))
        #expect(response.url == new)

        let entries = try await completed(2)
        #expect(entries.map(\.url) == [old, new])
        #expect(entries.map(\.statusCode) == [302, 200])
        #expect(entries.first?.responseHeaders["Location"] == new.absoluteString)
        #expect(entries.allSatisfy { $0.error == nil })
    }

    @Test func recordsCancellation() async throws {
        StubURLProtocol.handler = { _ in .hang }
        let session = self.session
        let request = Task { try await session.data(from: Self.base) }

        for _ in 0..<300 where Snitch.store.entries.isEmpty {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(Snitch.store.entries.first?.isComplete == false, "in-flight request is recorded as pending")

        request.cancel()
        let error = await #expect(throws: URLError.self) { try await request.value }
        #expect(error?.code == .cancelled)

        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == nil)
        #expect(entry.error != nil)
    }

    @Test func nothingCapturedWhenStopped() async throws {
        Snitch.stop()
        _ = try await session.data(from: Self.base)
        #expect(Snitch.store.entries.isEmpty)
    }

    @Test func pauseSkipsCaptureAndRecordsGap() async throws {
        Snitch.pause()
        #expect(Snitch.isPaused)
        _ = try await session.data(from: Self.base)
        #expect(Snitch.store.entries.isEmpty, "requests made while paused are not recorded")
        #expect(Snitch.store.pauses.last?.end == nil)

        Snitch.resume()
        #expect(!Snitch.isPaused)
        #expect(Snitch.store.pauses.last?.end != nil)
        _ = try await session.data(from: Self.base)
        #expect(try await completed(1).count == 1)
    }

    @Test func publicProtocolClassesCapture() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = Snitch.urlProtocolClasses + [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        _ = try await session.data(from: Self.base)
        #expect(try await completed(1).count == 1)
    }

    @Test func stopEndsPause() {
        Snitch.pause()
        Snitch.stop()
        #expect(!Snitch.isPaused)
        #expect(Snitch.store.pauses.last?.end != nil)
    }
}
