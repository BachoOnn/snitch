#if os(iOS)
import SwiftUI

/// Body lines with a find field, line numbers, and a truncation note when needed.
struct BodyCodeView: View {
    let lines: [[BodyToken]]
    /// How much of the body was kept.
    let storedSize: Int
    /// How large the body really was.
    let fullSize: Int

    @State private var query = ""
    /// The text is drawn from resolved colors, so it is rebuilt when the appearance changes.
    @Environment(\.colorScheme) private var colorScheme

    private static let gutterWidth: CGFloat = 34

    var body: some View {
        let matches = BodyFormatter.lines(matching: query, in: lines)
        VStack(alignment: .leading, spacing: 0) {
            BodyFindField(query: $query, matchCount: matches.count)
            Hairline()
            code(matches: matches)
            if fullSize > storedSize {
                DetailNote("Showing the first \(NetworkEntry.format(bytes: storedSize)) of \(NetworkEntry.format(bytes: fullSize))")
                    .padding([.horizontal, .bottom], Theme.Spacing.l)
            }
        }
        .cardStyle(fill: Theme.codeBackground, stroke: Theme.divider)
    }

    private func code(matches: Set<Int>) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.l) {
            SelectableText(text: BodyText.gutter(count: lines.count, matches: matches), wraps: false, selectable: false)
                .id(colorScheme)
                .frame(width: Self.gutterWidth, alignment: .trailing)
                .accessibilityHidden(true)
            ScrollView(.horizontal, showsIndicators: false) {
                SelectableText(text: BodyText.lines(lines, matches: matches), wraps: false)
                    .id(colorScheme)
                    .padding(.trailing, Theme.Spacing.l)
            }
        }
        .padding(.vertical, Theme.Spacing.m)
    }
}
#endif
