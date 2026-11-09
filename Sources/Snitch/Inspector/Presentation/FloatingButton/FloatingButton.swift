#if os(iOS)
import SwiftUI
import UIKit

/// Shows the floating activity dot that opens the inspector.
@MainActor
final class FloatingButton: NSObject {
    static let shared = FloatingButton()

    private static let size = Theme.Size.touchTarget
    private static let margin = Theme.Spacing.s
    /// How far below the top safe area the button first appears.
    private static let initialTopOffset: CGFloat = 64

    private let model = FloatingButtonModel()
    private var window: FloatingButtonWindow?
    private var wanted = false
    private var sceneObserver: NSObjectProtocol?
    /// The finger's offset from the button's center when the drag began.
    private var grabOffset: CGPoint = .zero

    /// Shows the button now, or as soon as the app has an active scene.
    func install() {
        wanted = true
        InspectorPresenter.onVisibilityChange = { [weak self] visible in
            self?.setHidden(visible)
        }
        showIfPossible()
        if window == nil { observeSceneActivation() }
    }

    /// Removes the button.
    func uninstall() {
        wanted = false
        window?.isHidden = true
        window = nil
        if let sceneObserver { NotificationCenter.default.removeObserver(sceneObserver) }
        sceneObserver = nil
    }

    // MARK: - Showing

    private func observeSceneActivation() {
        guard sceneObserver == nil else { return }
        sceneObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification, object: nil, queue: .main
        ) { _ in
            Task { @MainActor in FloatingButton.shared.showIfPossible() }
        }
    }

    private func setHidden(_ hidden: Bool) {
        window?.isHidden = hidden || !wanted
        if hidden { model.markSeen() }
    }

    private func showIfPossible() {
        guard wanted, window == nil, let scene = InspectorPresenter.activeScene else { return }
        let window = FloatingButtonWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.rootViewController = makeHost()
        window.frame = initialFrame(in: scene)
        // Taps and drags are handled in UIKit: a separate window gets them more reliably
        // than a SwiftUI button inside it.
        window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        window.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag(_:))))
        window.isHidden = InspectorPresenter.isPresented
        self.window = window
    }

    private func makeHost() -> UIViewController {
        let host = UIHostingController(rootView: FloatingDot(model: model))
        host.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            // The window is exactly the dot's size; safe-area insets would push the dot out of it.
            host.safeAreaRegions = []
        }
        return host
    }

    /// Top trailing corner, just under the navigation bar.
    private func initialFrame(in scene: UIWindowScene) -> CGRect {
        let bounds = scene.coordinateSpace.bounds
        let top = scene.appWindow?.safeAreaInsets.top ?? 0
        return CGRect(
            x: bounds.maxX - Self.size - Self.margin,
            y: top + Self.initialTopOffset,
            width: Self.size,
            height: Self.size
        )
    }

    // MARK: - Gestures

    @objc private func tap() {
        InspectorPresenter.present()
    }

    @objc private func drag(_ pan: UIPanGestureRecognizer) {
        // Measure the finger against the app's own window, which never moves, so the
        // button follows the finger exactly.
        guard let window, let anchor = window.windowScene?.appWindow else { return }
        let finger = pan.location(in: anchor)
        switch pan.state {
        case .began:
            grabOffset = CGPoint(x: window.center.x - finger.x, y: window.center.y - finger.y)
        case .changed:
            window.center = CGPoint(x: finger.x + grabOffset.x, y: finger.y + grabOffset.y)
        case .ended, .cancelled:
            window.center = CGPoint(x: finger.x + grabOffset.x, y: finger.y + grabOffset.y)
            keepOnScreen(window)
        default:
            break
        }
    }

    /// Leaves the button where it was dropped, only pulling it back inside the safe area.
    private func keepOnScreen(_ window: UIWindow) {
        guard let scene = window.windowScene else { return }
        let insets = scene.appWindow?.safeAreaInsets ?? .zero
        window.center = FloatingSnap.clamp(
            window.center,
            size: CGSize(width: Self.size, height: Self.size),
            in: scene.coordinateSpace.bounds.inset(by: insets),
            margin: Self.margin
        )
    }
}
#endif
