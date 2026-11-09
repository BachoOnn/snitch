#if os(iOS)
import SwiftUI
import UIKit

/// A window that holds only the floating button. It is the button's size and moves with
/// it, so it never covers or intercepts touches meant for the app.
final class FloatingButtonWindow: UIWindow {
    /// Claims every touch inside the window, even where the dot draws nothing.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return bounds.contains(point) ? (super.hitTest(point, with: event) ?? self) : nil
    }
}

/// Shows the floating activity dot that opens the inspector.
@MainActor
final class FloatingButton: NSObject {
    static let shared = FloatingButton()

    private static let size: CGFloat = 44
    private static let margin: CGFloat = 8

    private let model = FloatingButtonModel()
    private var window: FloatingButtonWindow?
    private var wanted = false
    private var sceneObserver: NSObjectProtocol?

    /// Shows the button now, or as soon as the app has an active scene.
    func install() {
        wanted = true
        InspectorPresenter.onVisibilityChange = { [weak self] visible in
            self?.setHidden(visible)
        }
        showIfPossible()
        if window == nil, sceneObserver == nil {
            sceneObserver = NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification, object: nil, queue: .main
            ) { _ in
                Task { @MainActor in FloatingButton.shared.showIfPossible() }
            }
        }
    }

    func uninstall() {
        wanted = false
        window?.isHidden = true
        window = nil
        if let sceneObserver { NotificationCenter.default.removeObserver(sceneObserver) }
        sceneObserver = nil
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

        let host = UIHostingController(rootView: FloatingDot(model: model))
        host.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            // The window is exactly the dot's size; safe-area insets would push the dot out of it.
            host.safeAreaRegions = []
        }
        window.rootViewController = host

        let bounds = scene.coordinateSpace.bounds
        let top = scene.windows.first?.safeAreaInsets.top ?? 0
        window.frame = CGRect(x: bounds.maxX - Self.size - Self.margin, y: top + 64, width: Self.size, height: Self.size)
        // Taps and drags are handled in UIKit: a separate window gets them more reliably
        // than a SwiftUI button inside it.
        window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        window.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag(_:))))
        window.isHidden = InspectorPresenter.isPresented
        self.window = window
    }

    @objc private func tap() {
        InspectorPresenter.present()
    }

    @objc private func drag(_ pan: UIPanGestureRecognizer) {
        guard let window else { return }
        let delta = pan.translation(in: nil)
        window.center = CGPoint(x: window.center.x + delta.x, y: window.center.y + delta.y)
        pan.setTranslation(.zero, in: nil)
        if pan.state == .ended || pan.state == .cancelled {
            snapToEdge(window)
        }
    }

    /// Moves the button to the nearest side, inside the safe area.
    private func snapToEdge(_ window: UIWindow) {
        guard let scene = window.windowScene else { return }
        let bounds = scene.coordinateSpace.bounds
        let insets = scene.windows.first { !($0 is FloatingButtonWindow) }?.safeAreaInsets ?? .zero
        let half = Self.size / 2
        let x = window.center.x < bounds.midX
            ? bounds.minX + insets.left + Self.margin + half
            : bounds.maxX - insets.right - Self.margin - half
        let minY = bounds.minY + insets.top + Self.margin + half
        let maxY = bounds.maxY - insets.bottom - Self.margin - half
        let y = min(max(window.center.y, minY), maxY)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            window.center = CGPoint(x: x, y: y)
        }
    }
}

/// Watches the store for the button's pulse and error badge.
@MainActor
final class FloatingButtonModel: ObservableObject {
    /// Changes every time a new request is recorded.
    @Published private(set) var activity = 0
    /// Whether a request failed or returned an error since the inspector was last opened.
    @Published private(set) var hasNewErrors = false

    private var lastSeen = Date()
    private var lastID: UUID?

    init() {
        Task { [weak self] in
            for await entries in Snitch.store.changes() {
                guard let self else { return }
                self.update(entries)
            }
        }
    }

    func markSeen() {
        lastSeen = Date()
        hasNewErrors = false
    }

    private func update(_ entries: [NetworkEntry]) {
        if let last = entries.last?.id, last != lastID {
            lastID = last
            activity += 1
        }
        hasNewErrors = entries.contains { entry in
            entry.startDate > lastSeen && [.clientError, .serverError, .failed].contains(entry.outcome)
        }
    }
}

/// The 32 pt green activity dot. Tap to open the inspector.
struct FloatingDot: View {
    @ObservedObject var model: FloatingButtonModel
    @State private var pulse = false

    var body: some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color(hex: 0x06210F))
            .frame(width: 32, height: 32)
            .background(Theme.accent, in: Circle())
            .overlay(Circle().strokeBorder(Color.white.opacity(0.35)))
            .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
            .scaleEffect(pulse ? 1.12 : 1)
            .overlay(alignment: .topTrailing) {
                if model.hasNewErrors {
                    Circle()
                        .fill(Color(hex: 0xFF5A4E))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))
                        .offset(x: 2, y: -2)
                }
            }
            .frame(width: 44, height: 44)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(model.hasNewErrors ? "Open network inspector, new errors" : "Open network inspector")
            .accessibilityAction { InspectorPresenter.present() }
            .onChange(of: model.activity) { _ in
                withAnimation(.easeOut(duration: 0.12)) { pulse = true }
                withAnimation(.easeIn(duration: 0.25).delay(0.12)) { pulse = false }
            }
    }
}
#endif
