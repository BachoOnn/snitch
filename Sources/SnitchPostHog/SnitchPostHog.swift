//
//  SnitchPostHog.swift
//  SnitchPostHog
//
//  Created by BOniani on 15/11/2026.
//

import PostHog
import Snitch
import UIKit

/// Shows the events your app sends to PostHog in Snitch's inspector.
///
/// Add ``beforeSend`` to your PostHog configuration. If you already use `beforeSend`
/// blocks to change or drop events, put Snitch's last so it shows what is actually sent:
///
/// ```swift
/// config.setBeforeSend(myRedaction, SnitchPostHog.beforeSend)
/// PostHogSDK.shared.setup(config)
/// ```
public enum SnitchPostHog {
    /// The name of PostHog's screen in the inspector.
    public static let source = "PostHog"

    /// A `beforeSend` block that records each event in Snitch and returns it unchanged.
    ///
    /// The one exception: screen views of Snitch's own UI, such as its floating button or
    /// the open inspector, are dropped instead of sent. Reading this property also adds the
    /// PostHog screen to the inspector. In non-`DEBUG` builds the block only returns the event.
    public static var beforeSend: BeforeSendBlock {
        Snitch.registerEventSource(source, icon: logo)
        return { event in
            #if DEBUG
            if isSnitchScreenView(name: event.event, properties: event.properties) {
                return nil
            }
            if let recorded = makeEvent(
                name: event.event,
                distinctId: event.distinctId,
                properties: event.properties,
                timestamp: event.timestamp,
                uuid: event.uuid
            ) {
                Snitch.record(recorded)
            }
            #endif
            return event
        }
    }

    static var logo: UIImage? {
        UIImage(named: "PostHogLogo", in: .module, with: nil)
    }

    private static let lifecycleEvents: Set<String> = [
        "Application Installed", "Application Updated", "Application Opened",
        "Application Became Active", "Application Backgrounded", "Deep Link Opened",
    ]

    static func isSnitchScreenView(name: String, properties: [String: Any]) -> Bool {
        name == "$screen" && Snitch.isOwnScreen(properties["$screen_name"] as? String ?? "")
    }

    static func makeEvent(
        name: String,
        distinctId: String,
        properties: [String: Any],
        timestamp: Date,
        uuid: UUID
    ) -> AnalyticsEvent? {
        guard name != "$snapshot" else { return nil }
        return AnalyticsEvent(
            source: source,
            name: name,
            userID: distinctId.isEmpty ? nil : distinctId,
            date: timestamp,
            id: uuid,
            isAutomatic: isPostHogOwn(name) || lifecycleEvents.contains(name),
            detail: name == "$screen" ? properties["$screen_name"] as? String : nil,
            properties: properties.filter { !isPostHogOwn($0.key) },
            sdkProperties: properties.filter { isPostHogOwn($0.key) }
        )
    }

    private static func isPostHogOwn(_ name: String) -> Bool {
        name.hasPrefix("$")
    }
}
