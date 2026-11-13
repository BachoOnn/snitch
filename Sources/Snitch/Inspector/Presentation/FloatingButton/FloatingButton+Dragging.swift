//
//  FloatingButton+Dragging.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import UIKit

/// The tap and drag gestures, kept apart from the button's lifecycle.
extension FloatingButton {
    // Moving a view inside a still, screen-sized window is smoother than moving the window.
    func expand(_ window: FloatingButtonWindow, button: UIView) {
        guard let bounds = window.windowScene?.coordinateSpace.bounds, window.frame != bounds else { return }
        let origin = window.frame.origin
        window.frame = bounds
        button.frame.origin = CGPoint(x: origin.x + button.frame.minX, y: origin.y + button.frame.minY)
    }

    func collapse(_ window: FloatingButtonWindow, button: UIView) {
        let frame = button.frame
        window.frame = frame
        button.frame.origin = .zero
    }

    @objc func tap() {
        InspectorPresenter.present()
    }

    @objc func drag(_ pan: UIPanGestureRecognizer) {
        guard let window, let button = window.button else { return }
        switch pan.state {
        case .began:
            settle?.stopAnimation(true)
            settle = nil
            expand(window, button: button)
            // From the first touch, not where the pan was recognized, so it stays under the finger.
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
            model.wake()
        default:
            break
        }
    }

    func settle(_ window: FloatingButtonWindow, button: UIView, velocity: CGPoint) {
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

extension FloatingButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        model.wake()
        if let window = gestureRecognizer.view {
            let point = touch.location(in: window)
            touchDown = CGPoint(x: point.x + window.frame.minX, y: point.y + window.frame.minY)
        }
        return true
    }
}
