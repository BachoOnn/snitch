//
//  SessionSettingsTests.swift
//  SnitchTests
//
//  Created by BOniani on 11/11/2026.
//

import Foundation
import Testing
@testable import Snitch

extension CaptureTests {
    /// Runs against a real local server, since cookies are handled by URLSession itself.
    @Suite(.serialized)
    final class SessionSettings {
        private let server: LocalHTTPServer

        init() async throws {
            server = try LocalHTTPServer()
            try await server.start()
            Snitch.start(showsButton: false, opensOnShake: false)
            clearSharedCookies()
        }

        deinit {
            server.stop()
            clearSharedCookies()
        }

        private func clearSharedCookies() {
            let shared = HTTPCookieStorage.shared
            for cookie in shared.cookies ?? [] where cookie.domain.contains("127.0.0.1") {
                shared.deleteCookie(cookie)
            }
        }

        private func sharedHasProbe() -> Bool {
            (HTTPCookieStorage.shared.cookies ?? []).contains { $0.name == "probe" && $0.domain.contains("127.0.0.1") }
        }

        private func session(_ configuration: URLSessionConfiguration) -> URLSession {
            Snitch.install(in: configuration)
            return URLSession(configuration: configuration)
        }

        private func body(_ session: URLSession, _ path: String) async throws -> String {
            let (data, _) = try await session.data(from: server.url(path))
            return String(decoding: data, as: UTF8.self)
        }

        @Test func cookiesGoToTheSessionsOwnStore() async throws {
            let configuration = URLSessionConfiguration.ephemeral
            let store = try #require(configuration.httpCookieStorage)
            let session = session(configuration)

            _ = try await body(session, "/set")
            #expect(store.cookies?.contains { $0.name == "probe" } == true)
            #expect(!sharedHasProbe(), "an ephemeral session's cookies must not reach the shared store")
            #expect(try await body(session, "/echo") == "probe=1")
        }

        @Test func clearingTheSessionsStoreLogsOut() async throws {
            let configuration = URLSessionConfiguration.ephemeral
            let store = try #require(configuration.httpCookieStorage)
            let session = session(configuration)
            _ = try await body(session, "/set")

            for cookie in store.cookies ?? [] { store.deleteCookie(cookie) }
            #expect(try await body(session, "/echo") == "none")
        }

        @Test func sessionWithCookiesOffSendsNone() async throws {
            _ = try await body(URLSession(configuration: .default), "/set")
            #expect(sharedHasProbe())

            let configuration = URLSessionConfiguration.default
            configuration.httpShouldSetCookies = false
            #expect(try await body(session(configuration), "/echo") == "none")
        }

        @Test func requestsAreStillCaptured() async throws {
            Snitch.store.clear()
            _ = try await body(session(.ephemeral), "/echo")
            #expect(Snitch.store.entries.contains { $0.url == server.url("/echo") })
        }
    }
}
