import SwiftUI
import UIKit

/// Shows the floating activity dot that opens the inspector.
@MainActor
final class FloatingButton: NSObject {
    static let shared = FloatingButton()

    private static let size = FloatingDot.frameSize
    private static let margin = Theme.Spacing.s
    /// How far below the top safe area the button first appears.
    private static let initialTopOffset: CGFloat = 64

    private let model = FloatingButtonModel()
    private var window: FloatingButtonWindow?
    private var wanted = false
    private var sceneObserver: NSObjectProtocol?
    /// Where the finger first touched the button, on screen.
    private var touchDown: CGPoint = .zero
    /// The finger's offset from the button's center when it first touched.
    private var grabOffset: CGPoint = .zero
    /// The settle after a drop, stopped if the button is grabbed again mid-flight.
    private var settle: UIViewPropertyAnimator?
    private let pickup = UIImpactFeedbackGenerator(style: .light)

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
        settle?.stopAnimation(true)
        settle = nil
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

        let root = FloatingRootController()
        let host = makeHost()
        root.addChild(host)
        host.view.frame = CGRect(x: 0, y: 0, width: Self.size, height: Self.size)
        // Keeps its size when the window spreads over the screen during a drag.
        host.view.autoresizingMask = []
        root.view.addSubview(host.view)
        host.didMove(toParent: root)
        window.rootViewController = root
        window.button = host.view
        window.frame = initialFrame(in: scene)

        // Taps and drags are handled in UIKit: a separate window gets them more reliably
        // than a SwiftUI button inside it.
        window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        pan.delegate = self
        window.addGestureRecognizer(pan)
        window.isHidden = InspectorPresenter.isPresented
        self.window = window
    }

    private func makeHost() -> UIViewController {
        let host = UIHostingController(rootView: FloatingDot(model: model))
        host.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            // The dot ignores the safe area wherever it is on screen.
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

    // MARK: - Moving

    // At rest the window is exactly the button's size, so it never touches the rest of
    // the app. While the button moves, the window covers the screen and stays still and
    // only the button moves inside it. Moving a window re-lays out its content on every
    // step; moving a view inside one does not, so the drag stays smooth.

    /// Spreads the window over the screen, keeping the button where it is.
    private func expand(_ window: FloatingButtonWindow, button: UIView) {
        guard let bounds = window.windowScene?.coordinateSpace.bounds, window.frame != bounds else { return }
        let origin = window.frame.origin
        window.frame = bounds
        button.frame.origin = CGPoint(x: origin.x + button.frame.minX, y: origin.y + button.frame.minY)
    }

    /// Shrinks the window back around the button.
    private func collapse(_ window: FloatingButtonWindow, button: UIView) {
        let frame = button.frame
        window.frame = frame
        button.frame.origin = .zero
    }

    // MARK: - Gestures

    @objc private func tap() {
        InspectorPresenter.present()
    }

    @objc private func drag(_ pan: UIPanGestureRecognizer) {
        guard let window, let button = window.button else { return }
        switch pan.state {
        case .began:
            // Catch it where it is on screen, even mid-bounce, so it never jumps.
            settle?.stopAnimation(true)
            settle = nil
            expand(window, button: button)
            // Measure from where the finger first touched, not where the drag was
            // recognized several points later, so the button stays under the finger.
            grabOffset = CGPoint(x: button.center.x - touchDown.x, y: button.center.y - touchDown.y)
            let finger = pan.location(in: window)
            button.center = CGPoint(x: finger.x + grabOffset.x, y: finger.y + grabOffset.y)
            pickup.impactOccurred()
        case .changed:
            let finger = pan.location(in: window)
            button.center = CGPoint(x: finger.x + grabOffset.x, y: finger.y + grabOffset.y)
        case .ended, .cancelled, .failed:
            let finger = pan.location(in: window)
            button.center = CGPoint(x: finger.x + grabOffset.x, y: finger.y + grabOffset.y)
            settle(window, button: button, velocity: pan.velocity(in: window))
        default:
            break
        }
    }

    /// Leaves the button where it was dropped. A drop that would leave it partly off
    /// screen springs back just inside the safe area.
    private func settle(_ window: FloatingButtonWindow, button: UIView, velocity: CGPoint) {
        let insets = window.windowScene?.appWindow?.safeAreaInsets ?? .zero
        let target = FloatingSnap.clamp(
            button.center,
            size: CGSize(width: Self.size, height: Self.size),
            in: window.bounds.inset(by: insets),
            margin: Self.margin
        )
        let path = CGPoint(x: target.x - button.center.x, y: target.y - button.center.y)
        let distanceSquared = path.x * path.x + path.y * path.y
        guard distanceSquared > 0.25 else {
            collapse(window, button: button)
            return
        }

        // The spring starts at the finger's speed toward the target, so release feels
        // continuous: a throw off screen first carries on, then bounces back.
        let toward = (velocity.x * path.x + velocity.y * path.y) / distanceSquared
        let timing = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: toward, dy: toward))
        let animator = UIViewPropertyAnimator(duration: 0.45, timingParameters: timing)
        animator.addAnimations { button.center = target }
        animator.addCompletion { [weak self, weak window] position in
            guard let self, let window, position == .end else { return }
            self.settle = nil
            self.collapse(window, button: button)
        }
        settle = animator
        animator.startAnimation()
    }
}

/// The floating window's root. While the window briefly covers the screen during a drag,
/// it leaves the status bar and rotation to the app.
private final class FloatingRootController: UIViewController {
    private var app: UIViewController? { InspectorPresenter.topViewController() }

    override var prefersStatusBarHidden: Bool { app?.prefersStatusBarHidden ?? false }
    override var preferredStatusBarStyle: UIStatusBarStyle { app?.preferredStatusBarStyle ?? .default }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        app?.supportedInterfaceOrientations ?? .all
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }
}

extension FloatingButton: UIGestureRecognizerDelegate {
    /// Notes where the finger lands, before the drag is recognized.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let window = gestureRecognizer.view {
            let point = touch.location(in: window)
            touchDown = CGPoint(x: point.x + window.frame.minX, y: point.y + window.frame.minY)
        }
        return true
    }
}
