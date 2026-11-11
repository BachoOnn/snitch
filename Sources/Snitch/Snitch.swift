import Foundation

/// Entry point for Snitch's network capture.
///
/// Capture only runs in `DEBUG` builds. In other builds every call here is a no-op,
/// so Snitch cannot record traffic in a release build by accident.
public enum Snitch {
    /// The library version.
    public static let version = "1.1.0"

    /// The store that receives every captured entry.
    public static let store = NetworkStore()

    private static let lock = NSLock()
    private static var running = false
    private static var paused = false
    private static var coversShared = false
    private static var ignored: Set<String> = []

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

    /// Whether `URLSession.shared` is being captured.
    static var isCapturingSharedSession: Bool {
        lock.withLock { coversShared }
    }

    /// Hosts whose requests Snitch leaves alone, such as analytics SDKs you don't
    /// want in the timeline. Each entry also covers its subdomains, so
    /// `"appsflyersdk.com"` skips `events.appsflyersdk.com` too.
    ///
    /// Skipped requests are never intercepted: they go straight to the network as if
    /// Snitch were not there. Set this before or after ``start(showsButton:opensOnShake:capturesSharedSession:)``.
    public static var ignoredHosts: Set<String> {
        get { lock.withLock { ignored } }
        set {
            let hosts = newValue.map { String($0.lowercased().drop { $0 == "." }) }.filter { !$0.isEmpty }
            lock.withLock { ignored = Set(hosts) }
        }
    }

    /// Whether requests to `host` are skipped by ``ignoredHosts``.
    static func isIgnored(host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }
        let ignored = ignoredHosts
        guard !ignored.isEmpty else { return false }
        return ignored.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    /// Starts capturing requests.
    ///
    /// - Parameters:
    ///   - showsButton: Shows a small floating button that opens the inspector.
    ///   - opensOnShake: Opens the inspector when the device is shaken.
    ///   - capturesSharedSession: Captures `URLSession.shared`, which third-party SDKs
    ///     often use too. Pass `false` to record only the sessions you add with
    ///     ``install(in:)`` or ``urlProtocolClasses``.
    public static func start(
        showsButton: Bool = true,
        opensOnShake: Bool = true,
        capturesSharedSession: Bool = true
    ) {
        #if DEBUG
        let started: Bool = lock.withLock {
            guard !running else { return false }
            running = true
            coversShared = capturesSharedSession
            if capturesSharedSession {
                URLProtocol.registerClass(SnitchURLProtocol.self)
            }
            return true
        }
        if started {
            DispatchQueue.main.async {
                if showsButton { FloatingButton.shared.install() }
                if opensOnShake { ShakeToOpen.isEnabled = true }
            }
        }
        #endif
    }

    /// Stops capturing new requests. Requests already in flight finish normally.
    public static func stop() {
        #if DEBUG
        lock.withLock {
            guard running else { return }
            running = false
            if coversShared {
                URLProtocol.unregisterClass(SnitchURLProtocol.self)
                coversShared = false
            }
            if paused {
                paused = false
                store.endPause()
            }
        }
        DispatchQueue.main.async {
            FloatingButton.shared.uninstall()
            ShakeToOpen.isEnabled = false
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

    /// Opens the inspector over the app's current screen.
    ///
    /// Use this to open Snitch from your own debug menu. It does nothing in non-`DEBUG`
    /// builds or when the inspector is already open.
    @MainActor
    public static func present() {
        #if DEBUG
        InspectorPresenter.present()
        #endif
    }

    /// The `URLProtocol` classes that capture traffic, for code that builds its own
    /// `protocolClasses` list and can't call ``install(in:)``, such as a networking
    /// package that doesn't depend on Snitch. Put them first in the list.
    ///
    /// Empty in non-`DEBUG` builds.
    public static var urlProtocolClasses: [AnyClass] {
        #if DEBUG
        [SnitchURLProtocol.self]
        #else
        []
        #endif
    }

    /// Adds Snitch to a custom session configuration.
    ///
    /// `start()` covers only `URLSession.shared`. Call this on a configuration before
    /// creating a `URLSession` from it; the session copies the configuration.
    /// Requests are captured only while ``isRunning`` is `true`.
    public static func install(in configuration: URLSessionConfiguration) {
        #if DEBUG
        var classes = configuration.protocolClasses ?? []
        guard !classes.contains(where: { $0 == SnitchURLProtocol.self }) else { return }
        classes.insert(SnitchURLProtocol.self, at: 0)
        configuration.protocolClasses = classes
        #endif
    }
}
