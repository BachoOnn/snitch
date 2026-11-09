import Foundation

/// A body split into rows for display, built once and away from the main thread.
///
/// Rows are shown lazily, so only the ones on screen are ever laid out. Very long
/// lines, such as minified JSON, are split into several rows so no single row is huge.
struct BodyDocument: Sendable {
    /// One row on screen: a whole line, or one piece of a long line.
    struct Row: Identifiable, Sendable {
        let id: Int
        /// The line number, or `nil` when the row continues the line above.
        let number: Int?
        let tokens: [BodyToken]
        /// The row's plain text, kept for find.
        let text: String
    }

    /// The longest row, in characters, before a line is split.
    static let maxRowLength = 400

    let rows: [Row]
    /// Whether the body is valid JSON, so it can be shown pretty or raw.
    let isJSON: Bool

    init(lines: [[BodyToken]], isJSON: Bool) {
        var rows: [Row] = []
        for (index, tokens) in lines.enumerated() {
            for (piece, pieceTokens) in Self.split(tokens).enumerated() {
                rows.append(Row(
                    id: rows.count,
                    number: piece == 0 ? index + 1 : nil,
                    tokens: pieceTokens,
                    text: pieceTokens.map(\.text).joined()
                ))
            }
        }
        self.rows = rows
        self.isJSON = isJSON
    }

    /// Formats `data` for display: pretty JSON when asked for and possible, otherwise
    /// the text as is. Returns `nil` for bodies that are not UTF-8 text.
    static func make(from data: Data, pretty: Bool) -> BodyDocument? {
        let isJSON = BodyFormatter.isJSON(data)
        guard let lines = BodyFormatter.lines(for: data, pretty: pretty && isJSON) else { return nil }
        return BodyDocument(lines: lines, isJSON: isJSON)
    }

    /// The text as shown, for copying. Split lines are joined back together.
    var text: String {
        var result = ""
        for row in rows {
            if row.number != nil, row.id > 0 { result += "\n" }
            result += row.text
        }
        return result
    }

    /// The ids of the rows that contain `query`, ignoring case and surrounding spaces.
    func rows(matching query: String) -> Set<Int> {
        let needle = query.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else { return [] }
        return Set(rows.lazy.filter { $0.text.range(of: needle, options: .caseInsensitive) != nil }.map(\.id))
    }

    /// Splits a line's tokens into pieces of at most ``maxRowLength`` characters.
    private static func split(_ tokens: [BodyToken]) -> [[BodyToken]] {
        var pieces: [[BodyToken]] = []
        var piece: [BodyToken] = []
        var length = 0
        for token in tokens {
            var rest = Substring(token.text)
            while length + rest.count > maxRowLength {
                let cut = rest.index(rest.startIndex, offsetBy: maxRowLength - length)
                if cut > rest.startIndex { piece.append(BodyToken(kind: token.kind, text: String(rest[..<cut]))) }
                pieces.append(piece)
                piece = []
                length = 0
                rest = rest[cut...]
            }
            if !rest.isEmpty || token.text.isEmpty {
                piece.append(BodyToken(kind: token.kind, text: String(rest)))
                length += rest.count
            }
        }
        pieces.append(piece)
        return pieces
    }
}
