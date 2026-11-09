#if os(iOS)
import SwiftUI

/// One header: name, value, and an eye button for sensitive values. Long press copies.
struct HeaderRow: View {
    let name: String
    let value: String
    /// Whether long values wrap instead of staying on one line.
    let expanded: Bool
    /// Copies text and shows a confirmation.
    let onCopy: (_ text: String, _ confirmation: String) -> Void

    @State private var revealed = false

    private static let nameWidth: CGFloat = 112
    private static let mask = "••••••••••••"

    private var isSensitive: Bool { SensitiveHeaders.contains(name) }
    private var isHidden: Bool { isSensitive && !revealed }

    var body: some View {
        HStack(spacing: Theme.Spacing.l) {
            Text(name)
                .foregroundStyle(Theme.secondary)
                .frame(width: Self.nameWidth, alignment: .leading)
                .lineLimit(1)
            Text(isHidden ? Self.mask : value)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(expanded ? nil : 1)
            if isSensitive { revealButton }
        }
        .font(Theme.mono(12, .regular))
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.vertical, Theme.Spacing.m)
        .contentShape(Rectangle())
        .contextMenu { menu }
    }

    private var revealButton: some View {
        Button { revealed.toggle() } label: {
            Image(systemName: isHidden ? "eye" : "eye.slash")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.chip, height: Theme.Size.chip)
        }
        .accessibilityLabel(isHidden ? "Show \(name)" : "Hide \(name)")
    }

    @ViewBuilder
    private var menu: some View {
        Button { onCopy(value, "Value copied") } label: {
            Label("Copy value", systemImage: "doc.on.doc")
        }
        Button { onCopy("\(name): \(value)", "Header copied") } label: {
            Label("Copy header", systemImage: "text.badge.plus")
        }
    }
}
#endif
