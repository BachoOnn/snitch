import Testing
@testable import Snitch

struct SensitiveHeadersTests {
    @Test(arguments: ["Authorization", "cookie", "Set-Cookie", "X-API-Key"])
    func hidesCredentials(name: String) {
        #expect(SensitiveHeaders.contains(name))
    }

    @Test(arguments: ["Content-Type", "Accept", "X-Request-Id"])
    func showsOrdinaryHeaders(name: String) {
        #expect(!SensitiveHeaders.contains(name))
    }

    @Test func sortsByNameIgnoringCase() {
        let sorted = SensitiveHeaders.sorted(["b": "2", "A": "1", "c": "3"])
        #expect(sorted.map(\.name) == ["A", "b", "c"])
    }
}
