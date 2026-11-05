#if os(iOS)
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
        let host = UIHostingController(rootView: InspectorView(onClose: { dismiss() }))
        host.modalPresentationStyle = .pageSheet
        if let controller = host.sheetPresentationController {
            controller.detents = [.large()]
            controller.prefersGrabberVisible = true
        }
        host.presentationController?.delegate = dismissObserver
        presenter.present(host, animated: true)
        sheet = host
        onVisibilityChange?(true)
    }

    static func dismiss() {
        sheet?.dismiss(animated: true) { onVisibilityChange?(false) }
        sheet = nil
    }

    /// The scene the user is looking at.
    static var activeScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    private static func topViewController() -> UIViewController? {
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
#endif
