import Foundation

/// Headers whose values the inspector hides until the user asks to see them.
enum SensitiveHeaders {
    private static let names: Set<String> = [
        "authorization", "proxy-authorization", "cookie", "set-cookie",
        "x-api-key", "api-key", "x-auth-token", "x-csrf-token",
    ]

    /// What a sensitive value is replaced with in shared text.
    static let redacted = "<redacted>"

    static func contains(_ name: String) -> Bool {
        names.contains(name.lowercased())
    }

    /// The same headers with every sensitive value replaced by ``redacted``.
    static func masked(_ headers: [String: String]) -> [String: String] {
        headers.reduce(into: [:]) { result, header in
            result[header.key] = contains(header.key) ? redacted : header.value
        }
    }

    /// Headers sorted by name, case-insensitively, so lists are stable.
    static func sorted(_ headers: [String: String]) -> [(name: String, value: String)] {
        headers.map { (name: $0.key, value: $0.value) }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
