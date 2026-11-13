//
//  CurlCommand.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import Foundation

extension NetworkEntry {
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

    static func shellQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
