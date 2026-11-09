#if os(iOS)
import ObjectiveC
import UIKit

/// Opens the inspector when the device is shaken.
///
/// Shake events reach `UIWindow.motionEnded(_:with:)` when nothing earlier in the
/// responder chain handles them. Snitch adds itself there once, always calling the
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
        let snitchSelector = #selector(UIWindow.snitch_motionEnded(_:with:))
        guard let original = class_getInstanceMethod(window, originalSelector),
              let snitch = class_getInstanceMethod(window, snitchSelector)
        else { return }
        if class_addMethod(window, originalSelector, method_getImplementation(snitch), method_getTypeEncoding(snitch)) {
            class_replaceMethod(window, snitchSelector, method_getImplementation(original), method_getTypeEncoding(original))
        } else {
            method_exchangeImplementations(original, snitch)
        }
    }()
}

extension UIWindow {
    @objc func snitch_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // After the exchange this calls the app's original implementation.
        snitch_motionEnded(motion, with: event)
        if motion == .motionShake, ShakeToOpen.isEnabled {
            Snitch.present()
        }
    }
}
#endif
