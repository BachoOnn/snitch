//
//  BodyDocument.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

struct BodyDocument: Sendable {
    struct Row: Identifiable, Sendable {
        let id: Int
        let number: Int?
        let tokens: [BodyToken]
        let text: String
    }

    static let maxRowLength = 400

    let rows: [Row]
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

    static func make(from data: Data, pretty: Bool) -> BodyDocument? {
        let isJSON = BodyFormatter.isJSON(data)
        guard let lines = BodyFormatter.lines(for: data, pretty: pretty && isJSON) else { return nil }
        return BodyDocument(lines: lines, isJSON: isJSON)
    }

    var text: String {
        var result = ""
        for row in rows {
            if row.number != nil, row.id > 0 { result += "\n" }
            result += row.text
        }
        return result
    }

    func rows(matching query: String) -> Set<Int> {
        let needle = query.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else { return [] }
        return Set(rows.lazy.filter { $0.text.range(of: needle, options: .caseInsensitive) != nil }.map(\.id))
    }

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
