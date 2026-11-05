import Foundation

extension NetworkEntry {
    /// A shell command that replays this request with curl.
    ///
    /// Headers are sorted so the output is stable. A body that is not UTF-8 text, or
    /// that was truncated when captured, is noted in a leading comment line.
    var curlCommand: String {
        var notes: [String] = []
        var parts = ["curl"]
        if method != "GET" { parts.append("-X \(method)") }
        parts.append(Self.shellQuoted(url?.absoluteString ?? ""))
        for (name, value) in requestHeaders.sorted(by: { $0.key.lowercased() < $1.key.lowercased() }) {
            parts.append("-H " + Self.shellQuoted("\(name): \(value)"))
        }
        if let body = requestBody {
            if let text = String(data: body, encoding: .utf8) {
                parts.append("--data-raw " + Self.shellQuoted(text))
                if requestBodySize > body.count { notes.append("# Body truncated to \(Self.format(bytes: body.count))") }
            } else {
                notes.append("# Binary body (\(Self.format(bytes: requestBodySize))) omitted")
            }
        }
        let command = parts.joined(separator: " \\\n  ")
        return (notes + [command]).joined(separator: "\n")
    }

    /// Wraps a value in single quotes for a POSIX shell.
    static func shellQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
