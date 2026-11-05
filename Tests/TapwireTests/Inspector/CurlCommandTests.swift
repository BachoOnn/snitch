import Foundation
import Testing
@testable import Tapwire

struct CurlCommandTests {
    @Test func simpleGet() {
        let entry = NetworkEntry(url: URL(string: "https://api.example.test/users?page=2"), method: "GET")
        #expect(entry.curlCommand == "curl \\\n  'https://api.example.test/users?page=2'")
    }

    @Test func postWithHeadersAndBody() {
        let entry = NetworkEntry(
            url: URL(string: "https://api.example.test/cart"),
            method: "POST",
            requestHeaders: ["Content-Type": "application/json", "Accept": "*/*"],
            requestBody: Data(#"{"sku":"TW-1"}"#.utf8)
        )
        #expect(entry.curlCommand == """
        curl \\
          -X POST \\
          'https://api.example.test/cart' \\
          -H 'Accept: */*' \\
          -H 'Content-Type: application/json' \\
          --data-raw '{"sku":"TW-1"}'
        """)
    }

    @Test func quotesSingleQuotes() {
        #expect(NetworkEntry.shellQuoted("it's") == #"'it'\''s'"#)
    }

    @Test func notesBinaryBody() {
        let entry = NetworkEntry(url: URL(string: "https://x.test"), method: "PUT", requestBody: Data([0xFF, 0xFE, 0x00]))
        #expect(entry.curlCommand.hasPrefix("# Binary body (3 B) omitted\ncurl"))
        #expect(!entry.curlCommand.contains("--data"))
    }

    @Test func notesTruncatedBody() {
        let body = Data(repeating: 0x61, count: NetworkEntry.maxStoredBodySize + 1)
        let entry = NetworkEntry(url: URL(string: "https://x.test"), method: "POST", requestBody: body)
        #expect(entry.curlCommand.hasPrefix("# Body truncated to 1.0 MB\n"))
    }
}
