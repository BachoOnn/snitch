import Foundation

/// A colored piece of a formatted body.
struct BodyToken: Equatable {
    enum Kind: Equatable { case key, string, number, literal, punctuation, plain }

    var kind: Kind
    var text: String
}

/// Turns captured bodies into lines for display.
enum BodyFormatter {
    /// Lines for a body: pretty, colored JSON when `pretty` is on and the body is JSON,
    /// otherwise the text as is. Returns `nil` for bodies that are not UTF-8 text.
    static func lines(for data: Data, pretty: Bool) -> [[BodyToken]]? {
        if pretty, let json = prettyJSON(data) { return json }
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        return text.components(separatedBy: .newlines).map { [BodyToken(kind: .plain, text: $0)] }
    }

    /// The body as text for copying: pretty JSON when possible, otherwise the raw text.
    static func copyText(for data: Data) -> String? {
        if let json = prettyJSON(data) {
            return json.map { $0.map(\.text).joined() }.joined(separator: "\n")
        }
        return String(data: data, encoding: .utf8)
    }

    /// Re-indents valid JSON two spaces per level, keeping the original key order.
    static func prettyJSON(_ data: Data) -> [[BodyToken]]? {
        guard (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)) != nil else {
            return nil
        }
        let bytes = [UInt8](data)
        var lines: [[BodyToken]] = []
        var line: [BodyToken] = []
        var depth = 0
        var i = 0

        func newLine() {
            lines.append(line)
            line = depth > 0 ? [BodyToken(kind: .plain, text: String(repeating: "  ", count: depth))] : []
        }
        func nextSignificant(after index: Int) -> UInt8? {
            var j = index
            while j < bytes.count, isSpace(bytes[j]) { j += 1 }
            return j < bytes.count ? bytes[j] : nil
        }
        func text(_ range: Range<Int>) -> String {
            String(decoding: bytes[range], as: UTF8.self)
        }

        while i < bytes.count {
            let byte = bytes[i]
            switch byte {
            case _ where isSpace(byte):
                i += 1
            case UInt8(ascii: "{"), UInt8(ascii: "["):
                let close: UInt8 = byte == UInt8(ascii: "{") ? UInt8(ascii: "}") : UInt8(ascii: "]")
                var j = i + 1
                while j < bytes.count, isSpace(bytes[j]) { j += 1 }
                if j < bytes.count, bytes[j] == close {
                    line.append(BodyToken(kind: .punctuation, text: text(i..<i + 1) + text(j..<j + 1)))
                    i = j + 1
                } else {
                    line.append(BodyToken(kind: .punctuation, text: text(i..<i + 1)))
                    depth += 1
                    newLine()
                    i += 1
                }
            case UInt8(ascii: "}"), UInt8(ascii: "]"):
                depth -= 1
                newLine()
                line.append(BodyToken(kind: .punctuation, text: text(i..<i + 1)))
                i += 1
            case UInt8(ascii: ","):
                line.append(BodyToken(kind: .punctuation, text: ","))
                newLine()
                i += 1
            case UInt8(ascii: ":"):
                line.append(BodyToken(kind: .punctuation, text: ": "))
                i += 1
            case UInt8(ascii: "\""):
                var j = i + 1
                while j < bytes.count, bytes[j] != UInt8(ascii: "\"") {
                    j += bytes[j] == UInt8(ascii: "\\") ? 2 : 1
                }
                let end = min(j + 1, bytes.count)
                let isKey = nextSignificant(after: end) == UInt8(ascii: ":")
                line.append(BodyToken(kind: isKey ? .key : .string, text: text(i..<end)))
                i = end
            default:
                var j = i
                while j < bytes.count, !isSpace(bytes[j]), !",]}:".utf8.contains(bytes[j]) { j += 1 }
                let word = text(i..<j)
                let kind: BodyToken.Kind = ["true", "false", "null"].contains(word) ? .literal : .number
                line.append(BodyToken(kind: kind, text: word))
                i = j
            }
        }
        lines.append(line)
        return lines
    }

    private static func isSpace(_ byte: UInt8) -> Bool {
        byte == 0x20 || byte == 0x0A || byte == 0x0D || byte == 0x09
    }
}
