//
//  SwipeReader.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import SwiftUI
import UIKit

/// Reports sideways swipes anywhere on the screen it is placed in, without getting in
/// the way of vertical scrolling.
///
/// It is a UIKit pan recognizer because SwiftUI drag gestures either miss drags that
/// start on a row's button or block the scroll view. The pan only begins when the drag
/// starts sideways, and once it does, the list doesn't scroll and the row under the finger
/// doesn't count it as a tap.
struct SwipeReader: UIViewRepresentable {
    let isEnabled: Bool
    let onSwipe: (_ translation: CGPoint, _ velocity: CGPoint) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> AnchorView {
        let view = AnchorView()
        view.recognizer = context.coordinator.recognizer
        return view
    }

    func updateUIView(_ view: AnchorView, context: Context) {
        context.coordinator.recognizer.isEnabled = isEnabled
        context.coordinator.onSwipe = onSwipe
    }

    static func dismantleUIView(_ view: AnchorView, coordinator: Coordinator) {
        coordinator.recognizer.view?.removeGestureRecognizer(coordinator.recognizer)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onSwipe: (CGPoint, CGPoint) -> Void = { _, _ in }

        private(set) lazy var recognizer: UIPanGestureRecognizer = {
            let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
            recognizer.delegate = self
            recognizer.delaysTouchesEnded = false
            return recognizer
        }()

        @objc private func pan(_ recognizer: UIPanGestureRecognizer) {
            guard recognizer.state == .ended, let view = recognizer.view else { return }
            onSwipe(recognizer.translation(in: view), recognizer.velocity(in: view))
        }

        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer else { return false }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > 2 * abs(velocity.y)
        }

        // Other drags, such as scrolling and pulling the sheet down, wait for the swipe to
        // fail, so a slightly diagonal swipe doesn't also move them. A vertical drag fails
        // the swipe as soon as it starts. A row's tap or long press gives way once the
        // swipe begins. Edge swipes are left alone so the back gesture keeps working.
        func gestureRecognizer(
            _ recognizer: UIGestureRecognizer,
            shouldBeRequiredToFailBy other: UIGestureRecognizer
        ) -> Bool {
            other is UIPanGestureRecognizer && !(other is UIScreenEdgePanGestureRecognizer)
        }
    }

    /// An invisible view that adds the recognizer to its screen's root view, so the
    /// swipe works on top of every row, not just on the empty space behind them.
    final class AnchorView: UIView {
        var recognizer: UIGestureRecognizer?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil, let recognizer, recognizer.view == nil else { return }
            screenView?.addGestureRecognizer(recognizer)
        }

        private var screenView: UIView? {
            sequence(first: self as UIResponder, next: \.next)
                .lazy
                .compactMap { $0 as? UIViewController }
                .first?
                .view
        }
    }
}
