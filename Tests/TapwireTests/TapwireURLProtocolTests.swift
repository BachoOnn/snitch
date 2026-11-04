import Foundation
import Testing
@testable import Tapwire

/// These tests share global state (`Tapwire.store`, protocol registration, the stub),
/// so they must run one at a time.
@Suite(.serialized)
final class TapwireURLProtocolTests {
    private static let base = URL(string: "https://api.tapwire.test")!
    private let session: URLSession

    /// The internal forwarding session talks to the stub instead of the network.
    private static let forwarder: Void = {
        let forwarding = URLSessionConfiguration.ephemeral
        forwarding.protocolClasses = [StubURLProtocol.self]
        TapwireURLProtocol.forwarder = Forwarder(configuration: forwarding)
    }()

    init() {
        Self.forwarder
        StubURLProtocol.reset()
        Tapwire.store.clear()
        Tapwire.start()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        Tapwire.install(in: configuration)
        session = URLSession(configuration: configuration)
    }

    deinit {
        session.invalidateAndCancel()
        Tapwire.stop()
    }

    /// Polls the store until `count` entries are complete.
    private func completed(_ count: Int, sourceLocation: SourceLocation = #_sourceLocation) async throws -> [NetworkEntry] {
        for _ in 0..<300 {
            let done = Tapwire.store.entries.filter(\.isComplete)
            if done.count >= count { return done }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        Issue.record("Timed out waiting for \(count) entries", sourceLocation: sourceLocation)
        return Tapwire.store.entries
    }

    @Test func installIsIdempotentAndFirst() {
        let configuration = URLSessionConfiguration.ephemeral
        Tapwire.install(in: configuration)
        Tapwire.install(in: configuration)
        let classes = configuration.protocolClasses ?? []
        #expect(classes.first == TapwireURLProtocol.self)
        #expect(classes.filter { $0 == TapwireURLProtocol.self }.count == 1)
    }

    @Test(arguments: [
        ("https://api.tapwire.test", true),
        ("http://api.tapwire.test", true),
        ("ftp://api.tapwire.test", false),
        ("file:///tmp/x", false),
    ])
    func canInitByScheme(url: String, expected: Bool) throws {
        let request = URLRequest(url: try #require(URL(string: url)))
        #expect(TapwireURLProtocol.canInit(with: request) == expected)
    }

    @Test func ignoresForwardedRequests() {
        let marked = NSMutableURLRequest(url: Self.base)
        URLProtocol.setProperty(true, forKey: TapwireURLProtocol.handledKey, in: marked)
        #expect(!TapwireURLProtocol.canInit(with: marked as URLRequest), "forwarded requests must not loop")
    }

    @Test func ignoresRequestsWhenStopped() {
        Tapwire.stop()
        #expect(!TapwireURLProtocol.canInit(with: URLRequest(url: Self.base)))
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

        for _ in 0..<300 where Tapwire.store.entries.isEmpty {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(Tapwire.store.entries.first?.isComplete == false, "in-flight request is recorded as pending")

        request.cancel()
        let error = await #expect(throws: URLError.self) { try await request.value }
        #expect(error?.code == .cancelled)

        let entry = try #require(try await completed(1).first)
        #expect(entry.statusCode == nil)
        #expect(entry.error != nil)
    }

    @Test func nothingCapturedWhenStopped() async throws {
        Tapwire.stop()
        _ = try await session.data(from: Self.base)
        #expect(Tapwire.store.entries.isEmpty)
    }
}
