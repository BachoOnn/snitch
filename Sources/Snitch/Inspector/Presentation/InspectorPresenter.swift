import SwiftUI
import UIKit

/// Presents the inspector as a full-height sheet over whatever the app is showing.
@MainActor
enum InspectorPresenter {
    private static weak var sheet: UIViewController?
    private static let dismissObserver = DismissObserver()

    /// Called when the inspector opens or closes, so the floating button can hide.
    static var onVisibilityChange: ((Bool) -> Void)?

    static var isPresented: Bool { sheet != nil }

    static func present() {
        guard sheet == nil, let presenter = topViewController() else { return }
        let host = InspectorHostingController(rootView: InspectorView(onClose: { dismiss() }))
        host.modalPresentationStyle = .pageSheet
        if let controller = host.sheetPresentationController {
            controller.detents = [.large()]
            controller.prefersGrabberVisible = true
        }
        host.presentationController?.delegate = dismissObserver
        KeyboardDismissal.shared.install(on: host.view)
        sheet = host
        // The button goes away before the sheet starts sliding up.
        onVisibilityChange?(true)
        presenter.present(host, animated: true)
    }

    static func dismiss() {
        guard let sheet else { return }
        sheet.dismiss(animated: true)
        self.sheet = nil
        // The button comes back right away rather than after the sheet has slid down.
        onVisibilityChange?(false)
    }

    /// The scene the user is looking at.
    static var activeScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    /// The screen on top of everything the app is showing, such as the inspector sheet.
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

    /// Notices when the user swipes the sheet away.
    @MainActor
    private final class DismissObserver: NSObject, UIAdaptivePresentationControllerDelegate {
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            InspectorPresenter.sheet = nil
            InspectorPresenter.onVisibilityChange?(false)
        }
    }
}
