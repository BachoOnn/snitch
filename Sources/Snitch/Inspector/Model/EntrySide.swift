import Foundation

/// Which half of an exchange the detail screen shows.
enum EntrySide: String, CaseIterable {
    case request = "Request"
    case response = "Response"
}

extension NetworkEntry {
    /// The headers sent or received on `side`.
    func headers(on side: EntrySide) -> [String: String] {
        side == .request ? requestHeaders : responseHeaders
    }

    /// The stored body on `side`, which may be truncated.
    func body(on side: EntrySide) -> Data? {
        side == .request ? requestBody : responseBody
    }

    /// The full size of the body on `side`, before any truncation.
    func bodySize(on side: EntrySide) -> Int {
        side == .request ? requestBodySize : responseBodySize
    }
}
