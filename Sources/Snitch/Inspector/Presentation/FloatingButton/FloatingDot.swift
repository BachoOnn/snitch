import SwiftUI

/// The green button with Snitch's S mark. It pulses on each new request and shows a badge after errors.
struct FloatingDot: View {
    @ObservedObject var model: FloatingButtonModel
    @State private var pulse = false

    /// The size of the dot, which is also its tap area.
    static let frameSize: CGFloat = 40
    private static let diameter = frameSize
    private static let badgeDiameter: CGFloat = 10

    var body: some View {
        SFlowMark()
            .stroke(
                Theme.onAccent,
                style: StrokeStyle(lineWidth: SFlowMark.lineWidth(for: Self.diameter), lineCap: .round, lineJoin: .round)
            )
            .frame(width: Self.diameter, height: Self.diameter)
            .background(Theme.accentFill, in: Circle())
            .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
            .scaleEffect(pulse ? 1.12 : 1)
            .overlay(alignment: .topTrailing) {
                if model.hasNewErrors { badge }
            }
            .frame(width: Self.frameSize, height: Self.frameSize)
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
            .offset(x: 1, y: -1)
    }

    private func pulseOnce() {
        withAnimation(.easeOut(duration: 0.12)) { pulse = true }
        withAnimation(.easeIn(duration: 0.25).delay(0.12)) { pulse = false }
    }
}
