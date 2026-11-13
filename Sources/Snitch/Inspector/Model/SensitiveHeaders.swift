//
//  SensitiveHeaders.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import Foundation

enum SensitiveHeaders {
    private static let names: Set<String> = [
        "authorization", "proxy-authorization", "cookie", "set-cookie",
        "x-api-key", "api-key", "x-auth-token", "x-csrf-token",
    ]

    static let redacted = "<redacted>"

    static func contains(_ name: String) -> Bool {
        names.contains(name.lowercased())
    }

    static func masked(_ headers: [String: String]) -> [String: String] {
        headers.reduce(into: [:]) { result, header in
            result[header.key] = contains(header.key) ? redacted : header.value
        }
    }

    static func sorted(_ headers: [String: String]) -> [(name: String, value: String)] {
        headers.map { (name: $0.key, value: $0.value) }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
