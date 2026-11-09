import SwiftUI

/// A request or response body: pretty or raw, with find and line numbers.
struct BodySection: View {
    let data: Data?
    /// The full size, which can be larger than `data` when the body was truncated.
    let size: Int
    /// Copies text and shows a confirmation.
    var onCopy: (_ text: String, _ confirmation: String) -> Void = { _, _ in }

    @State private var pretty = true

    var body: some View {
        let isJSON = data.flatMap(BodyFormatter.prettyJSON) != nil
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Text(title(isJSON: isJSON)).sectionLabelStyle()
                Spacer()
                if isJSON { BodyFormatToggle(pretty: $pretty) }
            }
            content(isJSON: isJSON)
        }
    }

    private func title(isJSON: Bool) -> String {
        guard let data, !data.isEmpty else { return "Body" }
        let kind = isJSON ? "JSON" : (String(data: data, encoding: .utf8) == nil ? "Binary" : "Text")
        return "Body · \(kind) · \(NetworkEntry.format(bytes: size))"
    }

    @ViewBuilder
    private func content(isJSON: Bool) -> some View {
        if let data, !data.isEmpty {
            if let lines = BodyFormatter.lines(for: data, pretty: pretty && isJSON) {
                BodyCodeView(lines: lines, storedSize: data.count, fullSize: size) {
                    onCopy($0, "Body copied")
                }
                // New lines for pretty or raw, so the body is drawn again.
                .id(pretty)
            } else {
                DetailNote("Binary data · \(NetworkEntry.format(bytes: size))")
            }
        } else {
            DetailNote("No body")
        }
    }
}
