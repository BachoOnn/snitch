#if os(iOS)
import SwiftUI

/// The green activity dot. It pulses on each new request and shows a badge after errors.
struct FloatingDot: View {
    @ObservedObject var model: FloatingButtonModel
    @State private var pulse = false

    private static let diameter: CGFloat = 32
    private static let badgeDiameter: CGFloat = 10

    var body: some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Theme.onAccent)
            .frame(width: Self.diameter, height: Self.diameter)
            .background(Theme.accentFill, in: Circle())
            .overlay(Circle().strokeBorder(Color.white.opacity(0.35)))
            .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
            .scaleEffect(pulse ? 1.12 : 1)
            .overlay(alignment: .topTrailing) {
                if model.hasNewErrors { badge }
            }
            .frame(width: Theme.Size.touchTarget, height: Theme.Size.touchTarget)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(model.hasNewErrors ? "Open network inspector, new errors" : "Open network inspector")
            .accessibilityAction { InspectorPresenter.present() }
            .onChange(of: model.activity) { _ in pulseOnce() }
    }

    private var badge: some View {
        Circle()
            .fill(Theme.badge)
            .frame(width: Self.badgeDiameter, height: Self.badgeDiameter)
            .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))
            .offset(x: 2, y: -2)
    }

    private func pulseOnce() {
        withAnimation(.easeOut(duration: 0.12)) { pulse = true }
        withAnimation(.easeIn(duration: 0.25).delay(0.12)) { pulse = false }
    }
}
#endif
