//
//  InspectorPresenter.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI
import UIKit

@MainActor
enum InspectorPresenter {
    private static weak var sheet: UIViewController?
    private static let dismissObserver = DismissObserver()

    static var onVisibilityChange: ((Bool) -> Void)?

    static var isPresented: Bool { sheet != nil }

    static func present() {
        guard sheet == nil, let presenter = topViewController() else { return }
        onVisibilityChange?(true)
        // Commit the hide now; building the inspector blocks the main thread.
        CATransaction.flush()
        let host = InspectorHostingController(rootView: InspectorView(onClose: { dismiss() }))
        host.modalPresentationStyle = .pageSheet
        if let controller = host.sheetPresentationController {
            controller.detents = [.large()]
            controller.prefersGrabberVisible = true
        }
        host.presentationController?.delegate = dismissObserver
        KeyboardDismissal.shared.install(on: host.view)
        sheet = host
        presenter.present(host, animated: true)
    }

    static func dismiss() {
        guard let sheet else { return }
        sheet.dismiss(animated: true)
        self.sheet = nil
        onVisibilityChange?(false)
    }

    static var activeScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    static func topViewController() -> UIViewController? {
        guard let scene = activeScene else { return nil }
        let appWindows = scene.windows.filter { $0.windowLevel == .normal }
        let window = appWindows.first(where: \.isKeyWindow) ?? appWindows.first
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    @MainActor
    private final class DismissObserver: NSObject, UIAdaptivePresentationControllerDelegate {
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            presentationController.presentedViewController.transitionCoordinator?.notifyWhenInteractionChanges { context in
                if !context.isCancelled { InspectorPresenter.onVisibilityChange?(false) }
            }
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            InspectorPresenter.sheet = nil
            InspectorPresenter.onVisibilityChange?(false)
        }
    }
}
