//
//  Snitch+Events.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import UIKit

extension Snitch {
    static let events = EventStore()

    /// Adds a screen for an analytics SDK to the inspector, even before its first event.
    ///
    /// Adapters such as `SnitchPostHog` call this for you. Does nothing when Snitch isn't
    /// enabled (see ``isEnabled``).
    ///
    /// - Parameters:
    ///   - source: The SDK's name, such as `PostHog`.
    ///   - icon: A small image for the screen's switcher tab. Without one, a chart symbol is used.
    public static func registerEventSource(_ source: String, icon: UIImage? = nil) {
        guard isEnabled else { return }
        events.register(source: source, icon: icon)
    }

    /// Records an analytics event so it shows on its source's screen in the inspector.
    ///
    /// Events are recorded only while Snitch is running and not paused. Safe to call from
    /// any thread. Does nothing when Snitch isn't enabled (see ``isEnabled``).
    public static func record(_ event: AnalyticsEvent) {
        guard isCapturing else { return }
        events.insert(event)
    }
}
