import Foundation

/// Plain text the inspector shows for an entry.
extension NetworkEntry {
    /// Requests at or above this duration are marked as slow.
    static let slowThreshold: TimeInterval = 1

    /// Path and query, such as `/v2/products?page=2`.
    var displayPath: String {
        guard let url else { return "?" }
        let path = url.path.isEmpty ? "/" : url.path
        return url.query.map { path + "?" + $0 } ?? path
    }

    var displayHost: String {
        url?.host ?? ""
    }

    /// The status code, or a word when there is none.
    var displayStatus: String {
        switch outcome {
        case .pending: return "···"
        case .failed: return statusCode.map(String.init) ?? "Failed"
        default: return statusCode.map(String.init) ?? ""
        }
    }

    /// The standard reason phrase for the status code, such as `Created`.
    var reasonPhrase: String? {
        guard let statusCode else { return nil }
        if let phrase = Self.reasonPhrases[statusCode] { return phrase }
        // The system's wording is unusual for some codes (200 is "no error"), so it is only a fallback.
        let phrase = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        return phrase.prefix(1).uppercased() + phrase.dropFirst()
    }

    /// Standard reason phrases for the most common status codes.
    private static let reasonPhrases: [Int: String] = [
        200: "OK", 201: "Created", 202: "Accepted", 204: "No Content",
        301: "Moved Permanently", 302: "Found", 304: "Not Modified", 307: "Temporary Redirect", 308: "Permanent Redirect",
        400: "Bad Request", 401: "Unauthorized", 403: "Forbidden", 404: "Not Found", 405: "Method Not Allowed",
        409: "Conflict", 410: "Gone", 415: "Unsupported Media Type", 422: "Unprocessable Content", 429: "Too Many Requests",
        500: "Internal Server Error", 501: "Not Implemented", 502: "Bad Gateway", 503: "Service Unavailable", 504: "Gateway Timeout",
    ]

    var displayDuration: String? {
        duration.map(Self.format(duration:))
    }

    var isSlow: Bool {
        (duration ?? 0) >= Self.slowThreshold
    }

    /// One line for bug reports: `POST https://api.example.com/cart → 201 (88 ms)`.
    var summary: String {
        var line = "\(method) \(url?.absoluteString ?? "?") → \(displayStatus)"
        if let displayDuration { line += " (\(displayDuration))" }
        return line
    }

    static func format(duration: TimeInterval) -> String {
        duration < 1
            ? "\(Int((duration * 1000).rounded())) ms"
            : String(format: "%.1f s", duration)
    }

    static func format(bytes: Int) -> String {
        switch bytes {
        case ..<1024: return "\(bytes) B"
        case ..<(1024 * 1024): return "\(Int((Double(bytes) / 1024).rounded())) KB"
        default: return String(format: "%.1f MB", Double(bytes) / 1_048_576)
        }
    }
}
