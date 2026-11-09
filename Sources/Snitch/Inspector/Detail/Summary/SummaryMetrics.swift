#if os(iOS)
import SwiftUI

/// Duration · response size · start time, under a hairline at the bottom of the summary card.
struct SummaryMetrics: View {
    let entry: NetworkEntry

    var body: some View {
        HStack(spacing: Theme.Spacing.xl) {
            Text(entry.displayDuration ?? "pending")
            separator
            Text(NetworkEntry.format(bytes: entry.responseBodySize))
            separator
            Text(entry.startDate.formatted(date: .omitted, time: .standard))
        }
        .font(Theme.mono(12))
        .foregroundStyle(Theme.textMuted)
        .padding(.top, Theme.Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Hairline(color: Theme.border) }
    }

    private var separator: some View {
        Rectangle().fill(Theme.control).frame(width: Theme.Size.hairline, height: 12)
    }
}
#endif
