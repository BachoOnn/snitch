import Foundation
import Testing
@testable import Snitch

struct EntryFormattingTests {
    private func entry(
        _ url: String = "https://api.example.test/v2/products?page=2",
        status: Int? = nil,
        duration: TimeInterval? = nil,
        error: String? = nil
    ) -> NetworkEntry {
        var entry = NetworkEntry(url: URL(string: url), method: "GET")
        entry.statusCode = status
        entry.duration = duration
        entry.error = error
        return entry
    }

    @Test(arguments: [
        (nil, nil, nil, NetworkEntry.Outcome.pending),
        (200, 0.1, nil, .success),
        (304, 0.1, nil, .success),
        (404, 0.1, nil, .clientError),
        (503, 0.1, nil, .serverError),
        (nil, 0.1, "offline", .failed),
        (200, 0.1, "cancelled", .failed),
    ] as [(Int?, TimeInterval?, String?, NetworkEntry.Outcome)])
    func outcome(status: Int?, duration: TimeInterval?, error: String?, expected: NetworkEntry.Outcome) {
        #expect(entry(status: status, duration: duration, error: error).outcome == expected)
    }

    @Test func pathAndHost() {
        let e = entry()
        #expect(e.displayPath == "/v2/products?page=2")
        #expect(e.displayHost == "api.example.test")
        #expect(entry("https://api.example.test").displayPath == "/")
    }

    @Test func status() {
        #expect(entry().displayStatus == "···")
        #expect(entry(status: 201, duration: 0.1).displayStatus == "201")
        #expect(entry(duration: 0.1, error: "offline").displayStatus == "Failed")
        #expect(entry(status: 201, duration: 0.1).reasonPhrase == "Created")
    }

    @Test(arguments: [(200, "OK"), (304, "Not Modified"), (429, "Too Many Requests"), (503, "Service Unavailable")])
    func reasonPhrases(code: Int, phrase: String) {
        #expect(entry(status: code, duration: 0.1).reasonPhrase == phrase)
    }

    @Test(arguments: [(0.088, "88 ms"), (0.9996, "1000 ms"), (1.4, "1.4 s"), (12.0, "12.0 s")])
    func duration(seconds: TimeInterval, text: String) {
        #expect(NetworkEntry.format(duration: seconds) == text)
    }

    @Test(arguments: [(512, "512 B"), (18_400, "18 KB"), (1_258_291, "1.2 MB")])
    func size(bytes: Int, text: String) {
        #expect(NetworkEntry.format(bytes: bytes) == text)
    }

    @Test func slow() {
        #expect(!entry(status: 200, duration: 0.9).isSlow)
        #expect(entry(status: 200, duration: 1.0).isSlow)
    }

    @Test func summary() {
        #expect(entry(status: 201, duration: 0.088).summary == "GET https://api.example.test/v2/products?page=2 → 201 (88 ms)")
        #expect(entry().summary == "GET https://api.example.test/v2/products?page=2 → ···")
    }
}
