//
//  EntrySharingTests.swift
//  SnitchTests
//
//  Created by BOniani on 10/11/2026.
//

import Foundation
import Testing
@testable import Snitch

@Suite struct EntrySharingTests {
    private func entry() -> NetworkEntry {
        var entry = NetworkEntry(
            url: URL(string: "https://api.example.com/items"),
            method: "POST",
            requestHeaders: ["Authorization": "Bearer secret-token", "Content-Type": "application/json"],
            requestBody: Data(#"{"a":1}"#.utf8)
        )
        entry.statusCode = 200
        entry.responseHeaders = ["Set-Cookie": "session=abc", "Server": "nginx"]
        entry.duration = 0.1
        return entry
    }

    @Test func redactsOnlySensitiveHeaders() {
        let masked = SensitiveHeaders.masked(["authorization": "x", "X-API-Key": "y", "Accept": "*/*"])
        #expect(masked == ["authorization": SensitiveHeaders.redacted, "X-API-Key": SensitiveHeaders.redacted, "Accept": "*/*"])
    }

    @Test func sharedReportHidesTokensButKeepsTheRest() {
        let text = entry().maskingSensitiveHeaders.reportText
        #expect(!text.contains("secret-token"))
        #expect(!text.contains("session=abc"))
        #expect(text.contains("Authorization: \(SensitiveHeaders.redacted)"))
        #expect(text.contains("Content-Type: application/json"))
        #expect(text.contains("Server: nginx"))
        #expect(text.contains(#""a": 1"#))
    }

    @Test func sharedCurlHidesTokens() {
        let curl = entry().maskingSensitiveHeaders.curlCommand
        #expect(!curl.contains("secret-token"))
        #expect(curl.contains("Authorization: \(SensitiveHeaders.redacted)"))
        #expect(curl.contains("--data-raw"))
    }

    @Test func copiedTextKeepsFullValues() {
        #expect(entry().reportText.contains("secret-token"))
        #expect(entry().curlCommand.contains("secret-token"))
    }
}
