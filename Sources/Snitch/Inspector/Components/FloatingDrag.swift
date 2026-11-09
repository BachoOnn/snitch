#if os(iOS)
import SwiftUI

/// Lets a floating control be dragged anywhere inside its container. When released it
/// settles on the nearest side, fully inside the container.
private struct FloatingDrag: ViewModifier {
    /// The resting center, or `nil` for the bottom-right corner.
    @Binding var center: CGPoint?
    /// `true` while the control is being dragged and briefly after, so a tap that ends a drag can be ignored.
    @Binding var isDragging: Bool
    let size: CGSize
    let margin: CGFloat

    @GestureState private var translation: CGSize = .zero

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let bounds = CGRect(origin: .zero, size: proxy.size)
            let resting = center.map { FloatingSnap.snap($0, size: size, in: bounds, margin: margin) }
                ?? FloatingSnap.bottomTrailing(size: size, in: bounds, margin: margin)

            content
                .position(x: resting.x + translation.width, y: resting.y + translation.height)
                .simultaneousGesture(
                    // Global coordinates, so the moving control does not shift its own frame of reference.
                    DragGesture(minimumDistance: 8, coordinateSpace: .global)
                        .updating($translation) { value, state, _ in state = value.translation }
                        .onChanged { _ in isDragging = true }
                        .onEnded { value in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { isDragging = false }
                            let dropped = CGPoint(x: resting.x + value.translation.width, y: resting.y + value.translation.height)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                center = FloatingSnap.snap(dropped, size: size, in: bounds, margin: margin)
                            }
                        }
                )
        }
    }
}

extension View {
    /// Makes this control draggable within its container; it snaps to the nearest side on release.
    func floatingDrag(center: Binding<CGPoint?>, isDragging: Binding<Bool>, size: CGSize, margin: CGFloat = 16) -> some View {
        modifier(FloatingDrag(center: center, isDragging: isDragging, size: size, margin: margin))
    }
}
#endif
