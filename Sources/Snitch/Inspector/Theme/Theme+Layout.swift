#if os(iOS)
import CoreGraphics

extension Theme {
    /// The spacing scale for padding and the gaps between views.
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let s: CGFloat = 8
        static let m: CGFloat = 10
        static let l: CGFloat = 12
        static let xl: CGFloat = 14
        static let xxl: CGFloat = 16
        static let xxxl: CGFloat = 20

        /// The horizontal margin of every screen.
        static let screen: CGFloat = 16
        /// Room left under scrolling content so the floating controls never cover it.
        static let floatingClearance: CGFloat = 100
    }

    /// Corner radii, named after the shapes that use them.
    enum Radius {
        static let toggle: CGFloat = 7
        static let segment: CGFloat = 10
        static let tile: CGFloat = 12
        static let card: CGFloat = 16
        static let panel: CGFloat = 20
    }

    /// Fixed sizes shared by several views.
    enum Size {
        /// The smallest comfortable tap area.
        static let touchTarget: CGFloat = 44
        /// Round floating buttons, such as filters and copy.
        static let floatingControl: CGFloat = 52
        static let field: CGFloat = 38
        static let chip: CGFloat = 28
        static let statusDot: CGFloat = 7
        static let hairline: CGFloat = 1
        static let methodPill = CGSize(width: 52, height: 28)
    }
}
#endif
