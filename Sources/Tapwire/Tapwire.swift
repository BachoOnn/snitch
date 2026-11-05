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
    public static func start() {
        #if DEBUG
        lock.withLock {
            guard !running else { return }
            running = true
            URLProtocol.registerClass(TapwireURLProtocol.self)
        }
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
