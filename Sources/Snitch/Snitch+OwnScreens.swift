//
//  Snitch+OwnScreens.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

extension Snitch {
    static var inspectorVisible = false

    private static let ownScreenNames: Set<String> = [
        String(describing: FloatingDot.self),
        String(describing: FloatingRootController.self),
    ]

    static var isInspectorVisible: Bool {
        lock.withLock { inspectorVisible }
    }

    static func setInspectorVisible(_ visible: Bool) {
        lock.withLock { inspectorVisible = visible }
    }

    /// Whether an automatic screen view with this name was caused by Snitch's own UI:
    /// its floating button, or any screen while the inspector is open.
    ///
    /// Analytics adapters use this so opening Snitch doesn't add screen views to your
    /// analytics. Safe to call from any thread.
    public static func isOwnScreen(_ screenName: String) -> Bool {
        isInspectorVisible || ownScreenNames.contains { screenName.contains($0) }
    }
}
