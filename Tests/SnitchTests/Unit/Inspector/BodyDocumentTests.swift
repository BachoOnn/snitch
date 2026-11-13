//
//  BodyDocumentTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import Foundation
import Testing
@testable import Snitch

@Suite struct BodyDocumentTests {
    @Test func numbersEachLine() throws {
        let document = try #require(BodyDocument.make(from: Data(#"{"a":1,"b":"x"}"#.utf8), pretty: true))
        #expect(document.isJSON)
        #expect(document.rows.map(\.number) == [1, 2, 3, 4])
        #expect(document.rows.map(\.text) == ["{", #"  "a": 1,"#, #"  "b": "x""#, "}"])
    }

    @Test func rawJSONStaysOnOneLineButKnowsItIsJSON() throws {
        let document = try #require(BodyDocument.make(from: Data(#"{"a":1}"#.utf8), pretty: false))
        #expect(document.isJSON)
        #expect(document.rows.map(\.text) == [#"{"a":1}"#])
    }

    @Test func splitsLongLinesIntoUnnumberedRows() throws {
        let line = String(repeating: "x", count: BodyDocument.maxRowLength * 2 + 5)
        let document = try #require(BodyDocument.make(from: Data("short\n\(line)\nend".utf8), pretty: false))
        #expect(document.rows.map(\.number) == [1, 2, nil, nil, 3])
        #expect(document.rows.map(\.text.count) == [5, BodyDocument.maxRowLength, BodyDocument.maxRowLength, 5, 3])
        #expect(document.text == "short\n\(line)\nend")
    }

    @Test func splitsInsideTokensAndKeepsTheirColors() {
        let long = BodyToken(kind: .string, text: String(repeating: "s", count: BodyDocument.maxRowLength + 1))
        let document = BodyDocument(lines: [[BodyToken(kind: .key, text: "k"), long]], isJSON: true)
        #expect(document.rows.count == 2)
        #expect(document.rows[0].tokens.map(\.kind) == [.key, .string])
        #expect(document.rows[1].tokens == [BodyToken(kind: .string, text: "ss")])
    }

    @Test func keepsEmptyLines() throws {
        let document = try #require(BodyDocument.make(from: Data("a\n\nb".utf8), pretty: false))
        #expect(document.rows.map(\.text) == ["a", "", "b"])
        #expect(document.text == "a\n\nb")
    }

    @Test func findsRowsIgnoringCaseAndSpaces() throws {
        let document = try #require(BodyDocument.make(from: Data("Alpha\nbeta\nALPHABET".utf8), pretty: false))
        #expect(document.rows(matching: "alpha") == [0, 2])
        #expect(document.rows(matching: "  beta ") == [1])
        #expect(document.rows(matching: "   ").isEmpty)
    }

    @Test func rejectsBinary() {
        #expect(BodyDocument.make(from: Data([0xFF, 0xFE, 0x00, 0xD8]), pretty: true) == nil)
    }

    @Test func buildsALargeBodyQuickly() throws {
        let items = (0..<3_000).map { "{\"id\":\($0),\"name\":\"Item \($0)\",\"tags\":[\"a\",\"b\"],\"active\":true}" }
        let data = Data(("[" + items.joined(separator: ",") + "]").utf8)
        let clock = ContinuousClock()
        var document: BodyDocument?
        let elapsed = clock.measure { document = BodyDocument.make(from: data, pretty: true) }
        #expect((document?.rows.count ?? 0) > 20_000)
        #expect(elapsed < .seconds(2))
    }
}
