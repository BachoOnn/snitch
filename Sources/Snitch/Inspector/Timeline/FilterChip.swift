import SwiftUI

/// A quiet, removable chip for one active filter.
struct FilterChip: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: Theme.Spacing.xxs) {
                Text(label)
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Theme.tertiary)
            }
            .font(Theme.mono(11))
            .foregroundStyle(Theme.textMuted)
            .padding(.leading, Theme.Spacing.m)
            .padding(.trailing, Theme.Spacing.s)
            .frame(height: Theme.Size.chip)
            .background(Theme.veil(0.04), in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.veil(0.09)))
        }
        .accessibilityLabel("Remove filter \(label)")
    }
}
