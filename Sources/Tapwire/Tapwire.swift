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

    /// Whether capture is currently on.
    public static var isRunning: Bool {
        lock.withLock { running }
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
