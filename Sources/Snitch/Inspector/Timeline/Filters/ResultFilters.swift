#if os(iOS)
import SwiftUI

/// The Failed and Pending toggles: outcomes that have no status code.
struct ResultFilters: View {
    @Binding var filter: EntryFilter

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            FilterToggleCell(isOn: filter.failed, accessibilityLabel: "Failed", action: { filter.failed.toggle() }) {
                label("Failed", dot: Circle().fill(Theme.danger))
            }
            FilterToggleCell(isOn: filter.pending, accessibilityLabel: "Pending", action: { filter.pending.toggle() }) {
                label("Pending", dot: Circle().strokeBorder(Theme.accent, lineWidth: 1.5))
            }
        }
        .padding(.horizontal, Theme.Spacing.m)
    }

    private func label<Dot: View>(_ text: String, dot: Dot) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            dot.frame(width: Theme.Size.statusDot, height: Theme.Size.statusDot)
            Text(text).font(.system(size: 13, weight: .semibold))
        }
        .frame(height: Theme.Size.field)
    }
}
#endif
