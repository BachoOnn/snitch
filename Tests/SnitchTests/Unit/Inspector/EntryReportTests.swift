//
//  EntryReportTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct EntryReportTests {
    private func completed() -> NetworkEntry {
        var entry = NetworkEntry(
            url: URL(string: "https://api.example.test/cart"),
            method: "POST",
            requestHeaders: ["Content-Type": "application/json", "Authorization": "Bearer abc"],
            requestBody: Data(#"{"sku":"TW-1"}"#.utf8)
        )
        entry.statusCode = 201
        entry.duration = 0.094
        entry.responseBody = Data([0xFF, 0xFE])
        entry.responseBodySize = 2
        return entry
    }

    @Test func includesSummaryHeadersAndPrettyBodies() {
        let report = completed().reportText
        #expect(report.hasPrefix("POST https://api.example.test/cart\nStatus: 201 Created\nDuration: 94 ms\n"))
        #expect(report.contains("""
        ── Request ──

        Headers (2)
          Authorization: Bearer abc
          Content-Type: application/json

        Body (14 B)
        {
          "sku": "TW-1"
        }
        """))
        #expect(report.hasSuffix("""
        ── Response ──

        Headers (0)
          none

        Body (2 B)
          binary data
        """))
    }

    @Test func describesPendingAndFailedRequests() {
        var entry = NetworkEntry(url: URL(string: "https://api.example.test/a"), method: "GET")
        #expect(entry.reportText.contains("Status: pending\nDuration: pending"))
        #expect(entry.reportText.contains("Body (0 B)\n  none"))

        entry.duration = 0.2
        entry.error = "offline"
        #expect(entry.reportText.contains("Status: no response"))
        #expect(entry.reportText.contains("Error: offline"))
    }

    @Test func notesTruncatedBodies() {
        var entry = completed()
        entry.responseBody = Data("partial".utf8)
        entry.responseBodySize = 2048
        #expect(entry.reportText.hasSuffix("partial\n… showing the first 7 B of 2 KB"))
    }

    @Test func joinsLinesBackIntoText() throws {
        let lines = try #require(BodyFormatter.prettyJSON(Data(#"{"a":1}"#.utf8)))
        #expect(BodyFormatter.text(of: lines) == "{\n  \"a\": 1\n}")
    }
}
