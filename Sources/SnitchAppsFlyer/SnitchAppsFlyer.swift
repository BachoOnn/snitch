//
//  SnitchAppsFlyer.swift
//  SnitchAppsFlyer
//
//  Created by BOniani on 17/11/2026.
//

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
    /// unchanged. Snitch finds AppsFlyer by name while the app runs, so it works with the
    /// AppsFlyer version your app already has, and does nothing in apps without it.
    /// Calling this more than once has no extra effect. Does nothing in non-`DEBUG` builds.
    public static func start() {
        #if DEBUG
        _ = started
        #endif
    }

    private static let started: Void = {
        guard let appsFlyer = NSClassFromString(className) else { return }
        Snitch.registerEventSource(source, icon: logo)
        LogEventHook.install(in: appsFlyer) { sdk, name, values in
            Snitch.record(makeEvent(name: name, values: values, userID: customerUserID(of: sdk)))
        }
    }()

    static let className = "AppsFlyerLib"

    static func customerUserID(of sdk: AnyObject) -> String? {
        guard let object = sdk as? NSObject, object.responds(to: NSSelectorFromString("customerUserID")) else { return nil }
        return object.value(forKey: "customerUserID") as? String
    }

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
