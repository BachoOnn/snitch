import SwiftUI

/// A round glass button face for floating actions, such as filters and copy.
struct GlassCircle: View {
    let systemImage: String
    /// A count shown in a small badge; hidden when zero.
    var badge: Int = 0

    private static let badgeSize: CGFloat = 16
    private static let badgeInset: CGFloat = 9

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Theme.text)
            .frame(width: Theme.Size.floatingControl, height: Theme.Size.floatingControl)
            .snitchGlass(in: Circle())
            .overlay(alignment: .topTrailing) { badgeView }
            .contentShape(Circle())
    }

    @ViewBuilder
    private var badgeView: some View {
        if badge > 0 {
            Text("\(badge)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.onAccent)
                .frame(minWidth: Self.badgeSize, minHeight: Self.badgeSize)
                .background(Theme.accentFill, in: Capsule())
                .offset(x: -Self.badgeInset, y: Self.badgeInset)
        }
    }
}
