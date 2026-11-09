import CoreGraphics

/// Where floating controls come to rest after being dragged.
enum FloatingSnap {
    /// Keeps a control exactly where it was dropped, only moving it the least needed
    /// to stay fully inside `bounds` with `margin` to spare.
    static func clamp(_ center: CGPoint, size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        let minX = bounds.minX + margin + size.width / 2
        let maxX = max(minX, bounds.maxX - margin - size.width / 2)
        let minY = bounds.minY + margin + size.height / 2
        let maxY = max(minY, bounds.maxY - margin - size.height / 2)
        return CGPoint(x: min(max(center.x, minX), maxX), y: min(max(center.y, minY), maxY))
    }

    /// The default resting place: the bottom-right corner.
    static func bottomTrailing(size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        CGPoint(x: bounds.maxX - margin - size.width / 2, y: bounds.maxY - margin - size.height / 2)
    }
}
