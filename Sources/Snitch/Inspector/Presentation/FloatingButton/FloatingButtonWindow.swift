import UIKit

/// A window that holds only the floating button. Touches anywhere but the button pass
/// through to the app, even while the window briefly covers the screen during a drag.
final class FloatingButtonWindow: UIWindow {
    /// The button's view.
    weak var button: UIView?

    /// Claims touches on the button, even where the dot draws nothing, and nothing else.
    /// Uses the on-screen position so a button still springing into place can be tapped.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let button else { return nil }
        let frame = button.layer.presentation()?.frame ?? button.frame
        return frame.contains(point) ? (super.hitTest(point, with: event) ?? button) : nil
    }
}

extension UIWindowScene {
    /// The app's own main window, not the floating button's.
    var appWindow: UIWindow? {
        windows.first { !($0 is FloatingButtonWindow) }
    }
}
