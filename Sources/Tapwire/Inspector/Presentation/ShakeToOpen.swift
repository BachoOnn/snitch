#if os(iOS)
import ObjectiveC
import UIKit

/// Opens the inspector when the device is shaken.
///
/// Shake events reach `UIWindow.motionEnded(_:with:)` when nothing earlier in the
/// responder chain handles them. Tapwire adds itself there once, always calling the
/// app's original implementation first.
@MainActor
enum ShakeToOpen {
    static var isEnabled = false

    static func enable() {
        _ = installOnce
        isEnabled = true
    }

    private static let installOnce: Void = {
        let window: AnyClass = UIWindow.self
        let originalSelector = #selector(UIResponder.motionEnded(_:with:))
        let tapwireSelector = #selector(UIWindow.tapwire_motionEnded(_:with:))
        guard let original = class_getInstanceMethod(window, originalSelector),
              let tapwire = class_getInstanceMethod(window, tapwireSelector)
        else { return }
        if class_addMethod(window, originalSelector, method_getImplementation(tapwire), method_getTypeEncoding(tapwire)) {
            class_replaceMethod(window, tapwireSelector, method_getImplementation(original), method_getTypeEncoding(original))
        } else {
            method_exchangeImplementations(original, tapwire)
        }
    }()
}

extension UIWindow {
    @objc func tapwire_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // After the exchange this calls the app's original implementation.
        tapwire_motionEnded(motion, with: event)
        if motion == .motionShake, ShakeToOpen.isEnabled {
            Tapwire.present()
        }
    }
}
#endif
