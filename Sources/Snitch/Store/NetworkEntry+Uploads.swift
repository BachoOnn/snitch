//
//  NetworkEntry+Uploads.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import Foundation

extension NetworkEntry {
    private static let idPattern = try! NSRegularExpression(
        pattern: "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        options: .caseInsensitive
    )

    static func unzipped(_ body: Data?) -> Data? {
        body.flatMap(Gzip.unzip).map { $0.prefix(maxStoredBodySize) }
    }

    static func ids(in body: Data?) -> Set<UUID> {
        guard let body, let text = String(data: body, encoding: .utf8) else { return [] }
        let matches = idPattern.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return Set(matches.compactMap { match in
            Range(match.range, in: text).flatMap { UUID(uuidString: String(text[$0])) }
        })
    }
}
