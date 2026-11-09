import UIKit

/// Hides the keyboard when the user taps anywhere outside a text field.
///
/// The tap is observed alongside everything else, so buttons, rows and menus keep
/// working. Taps on text fields and selectable text are ignored, so focusing a field or
/// selecting text never dismisses the keyboard.
@MainActor
final class KeyboardDismissal: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissal()

    func install(on view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func dismiss(_ tap: UITapGestureRecognizer) {
        tap.view?.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UITextField || current is UITextView { return false }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
