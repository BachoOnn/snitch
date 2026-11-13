//
//  EntrySideTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct EntrySideTests {
    @Test func picksTheRequestOrResponseHalf() {
        var entry = NetworkEntry(
            url: URL(string: "https://api.example.test/cart"),
            method: "POST",
            requestHeaders: ["Accept": "*/*"],
            requestBody: Data("sent".utf8)
        )
        entry.responseHeaders = ["Server": "test"]
        entry.responseBody = Data("received".utf8)
        entry.responseBodySize = 20

        #expect(entry.headers(on: .request) == ["Accept": "*/*"])
        #expect(entry.headers(on: .response) == ["Server": "test"])
        #expect(entry.body(on: .request) == Data("sent".utf8))
        #expect(entry.body(on: .response) == Data("received".utf8))
        #expect(entry.bodySize(on: .request) == 4)
        #expect(entry.bodySize(on: .response) == 20)
    }
}
