#if os(iOS)
import UIKit

/// A window that holds only the floating button. It is the button's size and moves with
/// it, so it never covers or intercepts touches meant for the app.
final class FloatingButtonWindow: UIWindow {
    /// Claims every touch inside the window, even where the dot draws nothing.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        bounds.contains(point) ? (super.hitTest(point, with: event) ?? self) : nil
    }
}

extension UIWindowScene {
    /// The app's own main window, not the floating button's.
    var appWindow: UIWindow? {
        windows.first { !($0 is FloatingButtonWindow) }
    }
}
#endif
