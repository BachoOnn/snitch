#if os(iOS)
import SwiftUI

/// The one-line summary shown in the navigation bar once the card scrolls away.
struct CompactSummary: View {
    let entry: NetworkEntry

    private static let maxWidth: CGFloat = 240

    var body: some View {
        let color = Theme.color(for: entry.outcome)
        HStack(spacing: Theme.Spacing.s) {
            Circle().fill(color).frame(width: Theme.Size.statusDot, height: Theme.Size.statusDot)
            Text(entry.displayStatus).foregroundStyle(color)
            Text(entry.method).foregroundStyle(Theme.textMuted)
            Text(entry.displayPath)
                .foregroundStyle(Theme.text)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(Theme.mono(13, .semibold))
        .frame(maxWidth: Self.maxWidth)
    }
}
#endif
