#if os(iOS)
import SwiftUI

/// The Request · Response switch pinned above the headers and body.
struct SidePicker: View {
    @Binding var selection: EntrySide

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
    }

    private func option(_ side: EntrySide) -> some View {
        let isSelected = selection == side
        return Button(side.rawValue) { selection = side }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isSelected ? Theme.onAccent : Theme.textMuted)
            .frame(maxWidth: .infinity, minHeight: Self.height)
            .background(isSelected ? Theme.accentFill : .clear, in: Capsule())
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
#endif
