//
//  Snitch+IgnoredHosts.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension Snitch {
    private static var ignored: Set<String> = []

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

    static func isIgnored(host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }
        let ignored = ignoredHosts
        guard !ignored.isEmpty else { return false }
        return ignored.contains { host == $0 || host.hasSuffix("." + $0) }
    }
}
