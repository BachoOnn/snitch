import SwiftUI

/// Body lines with a find field, line numbers, and a truncation note when needed.
struct BodyCodeView: View {
    let lines: [[BodyToken]]
    /// How much of the body was kept.
    let storedSize: Int
    /// How large the body really was.
    let fullSize: Int
    /// Copies the body as shown, pretty or raw.
    let onCopy: (String) -> Void

    @State private var query = ""
    @State private var render: BodyRender?
    /// The text is drawn from resolved colors, so it is redrawn when the appearance changes.
    @Environment(\.colorScheme) private var colorScheme

    private static let gutterWidth: CGFloat = 34

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                BodyFindField(query: $query, matchCount: render?.matchCount ?? 0)
                CopyChip(accessibilityLabel: "Copy body") { onCopy(BodyFormatter.text(of: lines)) }
                    .padding(.trailing, Theme.Spacing.m)
            }
            Hairline()
            if let render {
                code(render)
            } else {
                // Holds the body's height for the moment before it is drawn.
                Color.clear.frame(height: CGFloat(lines.count) * BodyText.lineHeight + 2 * Theme.Spacing.m)
            }
            if fullSize > storedSize {
                DetailNote("Showing the first \(NetworkEntry.format(bytes: storedSize)) of \(NetworkEntry.format(bytes: fullSize))")
                    .padding([.horizontal, .bottom], Theme.Spacing.l)
            }
        }
        .cardStyle(fill: Theme.codeBackground, stroke: Theme.divider)
        .onAppear(perform: redraw)
        .onChange(of: query) { _ in redraw() }
        .onChange(of: colorScheme) { _ in redraw() }
    }

    private func code(_ render: BodyRender) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.l) {
            SelectableText(text: render.gutter, wraps: false, selectable: false, size: render.gutterSize)
                .frame(width: Self.gutterWidth, alignment: .trailing)
                .accessibilityHidden(true)
            ScrollView(.horizontal, showsIndicators: false) {
                SelectableText(text: render.text, wraps: false, size: render.textSize)
                    .padding(.trailing, Theme.Spacing.l)
            }
        }
        .padding(.vertical, Theme.Spacing.m)
    }

    private func redraw() {
        render = BodyRender(lines: lines, query: query)
    }
}
