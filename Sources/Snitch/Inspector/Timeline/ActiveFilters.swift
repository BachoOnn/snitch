#if os(iOS)
import SwiftUI

/// The active filters as removable chips, under a `FILTERED · N` label.
struct ActiveFilters: View {
    @Binding var filter: EntryFilter

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            header
            FlowLayout(spacing: Theme.Spacing.xs) {
                ForEach(filter.tokens, id: \.self) { token in
                    FilterChip(label: token.label) { filter.remove(token) }
                }
            }
        }
        .padding(.top, Theme.Spacing.xxs)
        .padding(.bottom, Theme.Spacing.xxl)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.veil(0.07)).frame(height: Theme.Size.hairline)
        }
    }

    private var header: some View {
        HStack {
            Text("Filtered · \(filter.tokens.count)")
                .sectionLabelStyle()
                .foregroundStyle(Theme.tertiary)
            Spacer()
            Button("Clear") { filter = EntryFilter() }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondary)
        }
    }
}
#endif
