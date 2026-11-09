import Foundation

extension NetworkEntry {
    /// The whole exchange as readable text: a summary, then the request and response,
    /// each with every header and a pretty-printed body.
    ///
    /// Header values are included in full, sensitive ones too: this is what the user
    /// copies on purpose to share or paste elsewhere.
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
