import SwiftUI

/// The floating copy button on the detail screen. Tap copies the body,
/// long press offers more, and a drag moves it wherever the user drops it.
struct DetailCopyButton: View {
    let onCopy: () -> Void
    let onCopyAsCurl: () -> Void

    @State private var center: CGPoint? = Self.lastCenter
    @State private var isDragging = false

    /// Where the button was last left, so it stays put across detail screens.
    private static var lastCenter: CGPoint?

    var body: some View {
        Button {
            // A drag that ends on the button must not also copy.
            guard !isDragging else { return }
            onCopy()
        } label: {
            GlassCircle(systemImage: "doc.on.doc")
        }
        .accessibilityLabel("Copy")
        .accessibilityHint("Long press for more options. Drag to move.")
        .contextMenu { menu }
        .floatingDrag(
            center: $center,
            isDragging: $isDragging,
            size: CGSize(width: Theme.Size.floatingControl, height: Theme.Size.floatingControl)
        )
        // The keyboard should not push the button up over the content.
        .ignoresSafeArea(.keyboard)
        .onChange(of: center) { Self.lastCenter = $0 }
    }

    @ViewBuilder
    private var menu: some View {
        Button(action: onCopy) {
            Label("Copy", systemImage: "doc.on.doc")
        }
        Button(action: onCopyAsCurl) {
            Label("Copy as cURL", systemImage: "chevron.left.forwardslash.chevron.right")
        }
    }
}
