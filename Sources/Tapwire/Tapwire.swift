import Foundation

/// Entry point for Tapwire's network capture.
///
/// Capture only runs in `DEBUG` builds. In other builds every call here is a no-op,
/// so Tapwire cannot record traffic in a release build by accident.
public enum Tapwire {
    /// The library version.
    public static let version = "0.0.1"

    /// The store that receives every captured entry.
    public static let store = NetworkStore()

    private static let lock = NSLock()
    private static var running = false
    private static var paused = false

    /// Whether capture is currently on.
    public static var isRunning: Bool {
        lock.withLock { running }
    }

    /// Whether capture is paused. While paused, new requests are not recorded;
    /// the app's traffic itself is unaffected.
    public static var isPaused: Bool {
        lock.withLock { paused }
    }

    /// Whether a new request should be recorded right now.
    static var isCapturing: Bool {
        lock.withLock { running && !paused }
    }

    /// Starts capturing requests made through `URLSession.shared` and through any
    /// configuration passed to ``install(in:)``.
    ///
    /// - Parameter showsButton: Shows a small floating button that opens the inspector (iOS only).
    public static func start(showsButton: Bool = true) {
        #if DEBUG
        let started: Bool = lock.withLock {
            guard !running else { return false }
            running = true
            URLProtocol.registerClass(TapwireURLProtocol.self)
            return true
        }
        #if os(iOS)
        if started {
            DispatchQueue.main.async {
                if showsButton { FloatingButton.shared.install() }
            }
        }
        #endif
        #endif
    }

    /// Stops capturing new requests. Requests already in flight finish normally.
    public static func stop() {
        #if DEBUG
        lock.withLock {
            guard running else { return }
            running = false
            URLProtocol.unregisterClass(TapwireURLProtocol.self)
            if paused {
                paused = false
                store.endPause()
            }
        }
        #if os(iOS)
        DispatchQueue.main.async { FloatingButton.shared.uninstall() }
        #endif
        #endif
    }

    /// Stops recording new requests until ``resume()``. The gap is kept in the
    /// store as a ``NetworkStore/Pause``. Requests already in flight are still recorded.
    public static func pause() {
        #if DEBUG
        lock.withLock {
            guard running, !paused else { return }
            paused = true
            store.beginPause()
        }
        #endif
    }

    /// Resumes recording after ``pause()``.
    public static func resume() {
        #if DEBUG
        lock.withLock {
            guard paused else { return }
            paused = false
            store.endPause()
        }
        #endif
    }

    /// Opens the inspector over the app's current screen.
    ///
    /// Use this to open Tapwire from your own debug menu. It does nothing in non-`DEBUG`
    /// builds, on platforms other than iOS, or when the inspector is already open.
    @MainActor
    public static func present() {
        #if DEBUG && os(iOS)
        InspectorPresenter.present()
        #endif
    }

    /// Adds Tapwire to a custom session configuration.
    ///
    /// `start()` only covers `URLSession.shared`. Call this on a configuration before
    /// creating a `URLSession` from it; the session copies the configuration.
    /// Requests are captured only while ``isRunning`` is `true`.
    public static func install(in configuration: URLSessionConfiguration) {
        #if DEBUG
        var classes = configuration.protocolClasses ?? []
        guard !classes.contains(where: { $0 == TapwireURLProtocol.self }) else { return }
        classes.insert(TapwireURLProtocol.self, at: 0)
        configuration.protocolClasses = classes
        #endif
    }
}
