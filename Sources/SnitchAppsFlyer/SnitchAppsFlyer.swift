//
//  SnitchAppsFlyer.swift
//  SnitchAppsFlyer
//
//  Created by BOniani on 17/11/2026.
//

import AppsFlyerLib
import Snitch
import UIKit

/// Shows the in-app events your app logs to AppsFlyer in Snitch's inspector.
///
/// Call ``start()`` once, for example next to `Snitch.start()`. Your own AppsFlyer calls
/// stay as they are:
///
/// ```swift
/// Snitch.start()
/// SnitchAppsFlyer.start()
/// ```
public enum SnitchAppsFlyer {
    /// The name of AppsFlyer's screen in the inspector.
    public static let source = "AppsFlyer"

    /// Starts recording every event logged with AppsFlyer's `logEvent` methods, and adds
    /// the AppsFlyer screen to the inspector.
    ///
    /// AppsFlyer has no hook that sees events before they are sent, so Snitch wraps its two
    /// public `logEvent` methods. Each event is recorded, then passed on to AppsFlyer
    /// unchanged. Calling this more than once has no extra effect. Does nothing in
    /// non-`DEBUG` builds.
    public static func start() {
        #if DEBUG
        _ = started
        #endif
    }

    private static let started: Void = {
        Snitch.registerEventSource(source, icon: logo)
        LogEventHook.install(in: AppsFlyerLib.self) { sdk, name, values in
            Snitch.record(makeEvent(name: name, values: values, userID: (sdk as? AppsFlyerLib)?.customerUserID))
        }
    }()

    static var logo: UIImage? {
        UIImage(named: "AppsFlyerLogo", in: .module, with: nil)
    }

    static func makeEvent(name: String, values: [AnyHashable: Any]?, userID: String?, date: Date = Date()) -> AnalyticsEvent {
        let properties = Dictionary(
            (values ?? [:]).map { ("\($0.key)", $0.value) },
            uniquingKeysWith: { first, _ in first }
        )
        return AnalyticsEvent(
            source: source,
            name: name,
            userID: userID?.isEmpty == false ? userID : nil,
            date: date,
            properties: properties
        )
    }
}
