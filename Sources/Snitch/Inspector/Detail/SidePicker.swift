import SwiftUI

/// The Request · Response switch pinned above the headers and body.
///
/// A glass track with a green thumb that slides to the tapped side straight away.
/// The content below switches a frame later, so a large body never holds up the
/// thumb.
struct SidePicker: View {
    @Binding var selection: EntrySide

    /// The side the thumb shows, which leads `selection` by a frame.
    @State private var highlighted: EntrySide?
    @Namespace private var thumb

    private static let height: CGFloat = 36

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            ForEach(EntrySide.allCases, id: \.self, content: option)
        }
        .padding(Theme.Spacing.xxs)
        .snitchGlass(in: Capsule())
        .padding(.vertical, Theme.Spacing.m)
        // Opaque so content scrolling under the pinned picker stays hidden.
        .background(Theme.background)
        .onChange(of: selection) { highlighted = $0 }
    }

    private var current: EntrySide { highlighted ?? selection }

    private func option(_ side: EntrySide) -> some View {
        let isSelected = current == side
        return Text(side.rawValue)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isSelected ? Theme.onAccent : Theme.textMuted)
            .frame(maxWidth: .infinity, minHeight: Self.height)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.accentFill)
                        .matchedGeometryEffect(id: "thumb", in: thumb)
                }
            }
            .contentShape(Capsule())
            // A tap gesture rather than a button: buttons in a scroll view wait to
            // see whether a touch is a scroll before reacting.
            .onTapGesture { choose(side) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(side.rawValue)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityAction { choose(side) }
    }

    private func choose(_ side: EntrySide) {
        guard side != current else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) { highlighted = side }
        // Switch the content on the next frame, once the thumb is already moving.
        DispatchQueue.main.async { selection = side }
    }
}
