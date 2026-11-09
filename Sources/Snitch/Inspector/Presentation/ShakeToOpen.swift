import UIKit

/// Opens the inspector when the device is shaken, on a device or in the Simulator.
@MainActor
enum ShakeToOpen {
    static var isEnabled = false
}

extension UIWindow {
    /// Shake events reach the window when nothing earlier in the responder chain
    /// handles them. The event carries on as normal; Snitch only opens on top.
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake, ShakeToOpen.isEnabled {
            Snitch.present()
        }
    }
}
