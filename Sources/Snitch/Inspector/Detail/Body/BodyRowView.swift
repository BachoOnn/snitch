import SwiftUI

/// One body row: a line number and the colored text, wrapping when it is long.
struct BodyRowView: View {
    let row: BodyDocument.Row
    let isMatch: Bool

    static let gutterWidth: CGFloat = 34
    private static let font = Font.system(size: 12, design: .monospaced)

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.l) {
            Text(row.number.map(String.init) ?? "")
                .font(Self.font)
                .foregroundStyle(isMatch ? Theme.accent : Theme.faint)
                .frame(width: Self.gutterWidth, alignment: .trailing)
                .accessibilityHidden(true)
            colored
                .font(Self.font)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Theme.Spacing.l)
        .padding(.vertical, Theme.Spacing.xxxs)
        .background(isMatch ? Theme.accent.opacity(0.18) : Theme.codeBackground)
    }

    /// The tokens joined into one text, each in its own color.
    private var colored: Text {
        row.tokens.reduce(Text(verbatim: "")) { text, token in
            text + Text(verbatim: token.text).foregroundColor(Self.color(for: token.kind))
        }
    }

    private static func color(for kind: BodyToken.Kind) -> Color {
        switch kind {
        case .key: return Theme.jsonKey
        case .string: return Theme.jsonString
        case .number, .literal: return Theme.jsonNumber
        case .punctuation: return Theme.secondary
        case .plain: return Theme.text
        }
    }
}
