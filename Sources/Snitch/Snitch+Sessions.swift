//
//  Snitch+Sessions.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension Snitch {
    /// The `URLProtocol` classes that capture traffic, for code that builds its own
    /// `protocolClasses` list and can't call ``install(in:)``, such as a networking
    /// package that doesn't depend on Snitch. Put them first in the list.
    ///
    /// Requests captured this way are re-sent with default settings, so cookies go to
    /// the shared cookie store. Prefer ``install(in:)`` where you can.
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
    ///
    /// Captured requests are re-sent with this configuration's own settings, so its
    /// cookie store, cache, credentials and network policies behave as without Snitch.
    /// Background configurations are left alone, since they don't run protocol classes.
    public static func install(in configuration: URLSessionConfiguration) {
        #if DEBUG
        guard configuration.identifier == nil else { return }
        var classes = configuration.protocolClasses ?? []
        guard !classes.contains(where: { $0 is SnitchURLProtocol.Type }) else { return }
        classes.insert(SessionProtocols.makeClass(for: configuration), at: 0)
        configuration.protocolClasses = classes
        #endif
    }
}
