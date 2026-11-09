import Foundation
import Testing
@testable import Snitch

struct BodyFormatterTests {
    private func pretty(_ json: String) -> String? {
        BodyFormatter.prettyJSON(Data(json.utf8))?.map { $0.map(\.text).joined() }.joined(separator: "\n")
    }

    @Test func keepsKeyOrderAndIndents() {
        #expect(pretty(#"{"z":1,"a":[true,null,{"k":"v"}],"e":{}}"#) == """
        {
          "z": 1,
          "a": [
            true,
            null,
            {
              "k": "v"
            }
          ],
          "e": {}
        }
        """)
    }

    @Test func reformatsAlreadyIndentedJSON() {
        #expect(pretty("{\n    \"a\" : 1 ,\n \"b\":[ ]\n}") == "{\n  \"a\": 1,\n  \"b\": []\n}")
    }

    @Test func tagsTokenKinds() throws {
        let lines = try #require(BodyFormatter.prettyJSON(Data(#"{"name":"Tap \"wire\"","n":-1.5e3,"ok":false}"#.utf8)))
        let tokens = lines.flatMap { $0 }.filter { $0.kind != .plain && $0.kind != .punctuation }
        #expect(tokens == [
            BodyToken(kind: .key, text: #""name""#),
            BodyToken(kind: .string, text: #""Tap \"wire\"""#),
            BodyToken(kind: .key, text: #""n""#),
            BodyToken(kind: .number, text: "-1.5e3"),
            BodyToken(kind: .key, text: #""ok""#),
            BodyToken(kind: .literal, text: "false"),
        ])
    }

    @Test func keepsUnicode() {
        #expect(pretty(#"{"city":"თბილისი"}"#) == "{\n  \"city\": \"თბილისი\"\n}")
    }

    @Test func rejectsInvalidJSON() {
        #expect(BodyFormatter.prettyJSON(Data("not json".utf8)) == nil)
        #expect(BodyFormatter.prettyJSON(Data(#"{"a":"#.utf8)) == nil)
    }

    @Test func fallsBackToTextAndRejectsBinary() throws {
        let text = try #require(BodyFormatter.lines(for: Data("a=1\nb=2".utf8), pretty: true))
        #expect(text.map { $0.map(\.text).joined() } == ["a=1", "b=2"])
        #expect(BodyFormatter.lines(for: Data([0xFF, 0xFE]), pretty: false) == nil)
        #expect(BodyFormatter.lines(for: Data(#"{"a":1}"#.utf8), pretty: false)?.count == 1, "raw keeps the original text")
    }

    @Test func copyTextIsPrettyWhenPossible() {
        #expect(BodyFormatter.copyText(for: Data(#"{"a":1}"#.utf8)) == "{\n  \"a\": 1\n}")
        #expect(BodyFormatter.copyText(for: Data("plain".utf8)) == "plain")
    }
}
