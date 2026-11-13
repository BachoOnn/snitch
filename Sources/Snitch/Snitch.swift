//
//  Snitch.swift
//  Snitch
//
//  Created by BOniani on 04/11/2026.
//

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

    static let lock = NSLock()
    static var running = false
    static var paused = false
    static var coversShared = false

    /// Whether capture is currently on.
    public static var isRunning: Bool {
        lock.withLock { running }
    }

    /// Whether capture is paused. While paused, new requests are not recorded;
    /// the app's traffic itself is unaffected.
    public static var isPaused: Bool {
        lock.withLock { paused }
    }

    static var isCapturing: Bool {
        lock.withLock { running && !paused }
    }

    static var isCapturingSharedSession: Bool {
        lock.withLock { coversShared }
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
}
