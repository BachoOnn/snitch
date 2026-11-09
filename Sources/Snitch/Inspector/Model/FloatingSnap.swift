import CoreGraphics

/// Where floating controls come to rest after being dragged.
enum FloatingSnap {
    /// Moves a control's center to the nearest left or right side of `bounds`,
    /// keeping it fully inside with `margin` to spare.
    static func snap(_ center: CGPoint, size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let x = center.x < bounds.midX
            ? bounds.minX + margin + halfWidth
            : bounds.maxX - margin - halfWidth
        let minY = bounds.minY + margin + halfHeight
        let maxY = max(minY, bounds.maxY - margin - halfHeight)
        return CGPoint(x: x, y: min(max(center.y, minY), maxY))
    }

    /// The default resting place: the bottom-right corner.
    static func bottomTrailing(size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        CGPoint(x: bounds.maxX - margin - size.width / 2, y: bounds.maxY - margin - size.height / 2)
    }
}
