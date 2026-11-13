//
//  EntryReport.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

extension NetworkEntry {
    var reportText: String {
        var lines = [
            "\(method) \(url?.absoluteString ?? "?")",
            "Status: \(reportStatus)",
            "Duration: \(displayDuration ?? "pending")",
            "Started: \(startDate.formatted(date: .abbreviated, time: .standard))",
        ]
        if let error { lines.append("Error: \(error)") }
        for side in EntrySide.allCases {
            lines.append("")
            lines.append(contentsOf: reportSection(side))
        }
        return lines.joined(separator: "\n")
    }

    private var reportStatus: String {
        guard let statusCode else { return outcome == .pending ? "pending" : "no response" }
        return [String(statusCode), reasonPhrase].compactMap { $0 }.joined(separator: " ")
    }

    private func reportSection(_ side: EntrySide) -> [String] {
        let headers = SensitiveHeaders.sorted(headers(on: side))
        var lines = ["── \(side.rawValue) ──", "", "Headers (\(headers.count))"]
        lines += headers.isEmpty ? ["  none"] : headers.map { "  \($0.name): \($0.value)" }
        lines += ["", "Body (\(Self.format(bytes: bodySize(on: side))))", reportBody(side)]
        return lines
    }

    private func reportBody(_ side: EntrySide) -> String {
        guard let data = body(on: side), !data.isEmpty else { return "  none" }
        guard let text = BodyFormatter.copyText(for: data) else { return "  binary data" }
        let size = bodySize(on: side)
        guard size > data.count else { return text }
        return text + "\n… showing the first \(Self.format(bytes: data.count)) of \(Self.format(bytes: size))"
    }
}
