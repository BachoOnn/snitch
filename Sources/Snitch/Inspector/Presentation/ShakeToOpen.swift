import ObjectiveC
import UIKit

/// Opens the inspector when the device is shaken.
///
/// Shake events reach `UIWindow.motionEnded(_:with:)` when nothing earlier in the
/// responder chain handles them. Snitch wraps that method once, always calling the
/// app's original implementation first.
@MainActor
enum ShakeToOpen {
    static var isEnabled = false

    static func enable() {
        _ = installOnce
        isEnabled = true
    }

    private typealias Handler = @convention(c) (UIWindow, Selector, UIEvent.EventSubtype, UIEvent?) -> Void

    private static let installOnce: Void = {
        let selector = #selector(UIResponder.motionEnded(_:with:))
        guard let method = class_getInstanceMethod(UIWindow.self, selector) else { return }
        let original = unsafeBitCast(method_getImplementation(method), to: Handler.self)
        // The original runs with its own selector. UIKit forwards unhandled motion
        // events up the responder chain with that selector, so it must not be renamed.
        let wrapper: @convention(block) (UIWindow, UIEvent.EventSubtype, UIEvent?) -> Void = { window, motion, event in
            original(window, selector, motion, event)
            MainActor.assumeIsolated {
                if motion == .motionShake, isEnabled { Snitch.present() }
            }
        }
        let implementation = imp_implementationWithBlock(wrapper)
        // Add an override on UIWindow when it only inherits the method, so UIResponder
        // and its other subclasses are left alone.
        if !class_addMethod(UIWindow.self, selector, implementation, method_getTypeEncoding(method)) {
            method_setImplementation(method, implementation)
        }
    }()
}
