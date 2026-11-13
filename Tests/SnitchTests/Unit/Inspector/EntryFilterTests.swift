//
//  EntryFilterTests.swift
//  SnitchTests
//
//  Created by BOniani on 05/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct EntryFilterTests {
    private func entry(_ method: String = "GET", _ url: String = "https://api.example.test/users", status: Int? = nil, error: String? = nil, done: Bool = true) -> NetworkEntry {
        var entry = NetworkEntry(url: URL(string: url), method: method)
        entry.statusCode = status
        entry.error = error
        entry.duration = done ? 0.1 : nil
        return entry
    }

    @Test func emptyFilterMatchesEverything() {
        let filter = EntryFilter()
        #expect(filter.isEmpty)
        #expect(filter.matches(entry(status: 500)))
        #expect(filter.matches(entry(done: false)))
    }

    @Test func statusClassesAndCodesAreCombinedWithOr() {
        var filter = EntryFilter()
        filter.statusClasses = [.serverError]
        filter.addCode("404")
        #expect(filter.matches(entry(status: 503)))
        #expect(filter.matches(entry(status: 404)))
        #expect(!filter.matches(entry(status: 401)))
        #expect(!filter.matches(entry(status: 200)))
    }

    @Test func failedAndPending() {
        var filter = EntryFilter()
        filter.failed = true
        #expect(filter.matches(entry(error: "offline")))
        #expect(!filter.matches(entry(status: 200)))
        #expect(!filter.matches(entry(done: false)))
        filter.pending = true
        #expect(filter.matches(entry(done: false)))
    }

    @Test func methodHostAndSearchNarrowTheResult() {
        var filter = EntryFilter()
        filter.methods = ["POST"]
        filter.hosts = ["api.example.test"]
        #expect(filter.matches(entry("POST", status: 201)))
        #expect(!filter.matches(entry("GET", status: 201)))
        #expect(!filter.matches(entry("POST", "https://cdn.example.test/a", status: 201)))
        #expect(filter.matches(entry("POST", status: 201), search: "USERS"))
        #expect(!filter.matches(entry("POST", status: 201), search: "cart"))
        #expect(EntryFilter().matches(entry(status: 418), search: "418"))
    }

    @Test(arguments: [("404", true), (" 599 ", true), ("99", false), ("600", false), ("abc", false)])
    func addCodeValidates(text: String, accepted: Bool) {
        var filter = EntryFilter()
        #expect(filter.addCode(text) == accepted)
        #expect(filter.codes.isEmpty == !accepted)
    }

    @Test func tokensListAndRemoveFilters() {
        var filter = EntryFilter()
        filter.statusClasses = [.serverError, .clientError]
        filter.addCode("404")
        filter.addCode("404")
        filter.failed = true
        filter.methods = ["POST"]
        #expect(filter.tokens.map(\.label) == ["400", "500", "404", "Failed", "POST"])

        filter.remove(.code(404))
        filter.remove(.statusClass(.clientError))
        filter.remove(.failed)
        #expect(filter.tokens.map(\.label) == ["500", "POST"])
    }

    @Test func togglesAddAndRemove() {
        var filter = EntryFilter()
        filter.toggle(.serverError)
        filter.toggleMethod("POST")
        filter.toggleHost("api.example.test")
        #expect(filter.tokens.map(\.label) == ["500", "POST", "api.example.test"])
        filter.toggle(.serverError)
        filter.toggleMethod("POST")
        filter.toggleHost("api.example.test")
        #expect(filter.isEmpty)
    }
}

