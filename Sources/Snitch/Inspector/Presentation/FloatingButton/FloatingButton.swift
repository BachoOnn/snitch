//
//  FloatingButton.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI
import UIKit

@MainActor
final class FloatingButton: NSObject {
    static let shared = FloatingButton()

    static let size = FloatingDot.frameSize
    static let margin = Theme.Spacing.spacing8

    let model = FloatingButtonModel()
    var window: FloatingButtonWindow?
    private var wanted = false
    private var sceneObserver: NSObjectProtocol?
    var touchDown: CGPoint = .zero
    var grabOffset: CGPoint = .zero
    var settle: UIViewPropertyAnimator?
    let pickup = UIImpactFeedbackGenerator(style: .light)

    func install() {
        wanted = true
        InspectorPresenter.onVisibilityChange = { [weak self] visible in
            self?.setHidden(visible)
        }
        showIfPossible()
        if window == nil { observeSceneActivation() }
    }

    func uninstall() {
        wanted = false
        settle?.stopAnimation(true)
        settle = nil
        window?.isHidden = true
        window = nil
        if let sceneObserver { NotificationCenter.default.removeObserver(sceneObserver) }
        sceneObserver = nil
    }

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
        if hidden { model.markSeen() } else { model.wake() }
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
        host.view.autoresizingMask = []
        root.view.addSubview(host.view)
        host.didMove(toParent: root)
        window.rootViewController = root
        window.button = host.view
        window.frame = initialFrame(in: scene)

        window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        pan.delegate = self
        window.addGestureRecognizer(pan)
        window.isHidden = InspectorPresenter.isPresented
        self.window = window
        model.wake()
    }

    private func makeHost() -> UIViewController {
        let host = UIHostingController(rootView: FloatingDot(model: model))
        host.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            host.safeAreaRegions = []
        }
        return host
    }

    private func initialFrame(in scene: UIWindowScene) -> CGRect {
        let bounds = scene.coordinateSpace.bounds
        let top = scene.appWindow?.safeAreaInsets.top ?? 0
        return CGRect(
            x: bounds.maxX - Self.size - Self.margin,
            y: top + Theme.Spacing.floatingButtonInitialTop,
            width: Self.size,
            height: Self.size
        )
    }
}
