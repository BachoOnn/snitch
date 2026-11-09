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
        let phrase = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        return phrase.prefix(1).uppercased() + phrase.dropFirst()
    }

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
