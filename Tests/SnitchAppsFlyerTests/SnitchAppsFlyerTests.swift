//
//  SnitchAppsFlyerTests.swift
//  SnitchAppsFlyerTests
//
//  Created by BOniani on 17/11/2026.
//

import AppsFlyerLib
import Foundation
import Testing
@testable import Snitch
@testable import SnitchAppsFlyer

/// Stands in for AppsFlyerLib with the same two Objective-C methods, so the tests never call
/// AppsFlyer itself. Each test wraps its own class, since wrapping can't be undone.
class FakeSDK: NSObject {
    var received: [String] = []
    var completions = 0

    @objc(logEvent:withValues:)
    dynamic func logEvent(_ name: String, withValues values: [AnyHashable: Any]?) {
        received.append(name)
    }

    @objc(logEventWithEventName:eventValues:completionHandler:)
    dynamic func logEvent(name: String, values: [AnyHashable: Any]?, completionHandler: (([String: Any]?, Error?) -> Void)?) {
        received.append(name)
        completionHandler?(["status": "ok"], nil)
    }
}

final class WrappedSDK: FakeSDK {}

/// Has a method with AppsFlyer's name but different arguments, which must be left alone.
final class OtherSDK: NSObject {
    var received: [Int] = []

    @objc(logEvent:withValues:)
    dynamic func logEvent(_ code: Int, withValues flag: Bool) {
        received.append(code)
    }
}

struct SnitchAppsFlyerTests {
    @Test func reportsEachEventOnceAndStillLogsIt() {
        var reported: [String] = []
        let wrapped = LogEventHook.install(in: WrappedSDK.self) { _, name, values in
            reported.append("\(name) \(values?.count ?? 0)")
        }
        #expect(wrapped == 2)

        let sdk = WrappedSDK()
        sdk.logEvent("af_login", withValues: nil)
        sdk.logEvent(name: "af_purchase", values: ["af_revenue": 9.99, "af_currency": "USD"]) { _, _ in
            sdk.completions += 1
        }

        #expect(reported == ["af_login 0", "af_purchase 2"])
        #expect(sdk.received == ["af_login", "af_purchase"])
        #expect(sdk.completions == 1)
    }

    @Test func leavesMethodsWithOtherArgumentsAlone() {
        let wrapped = LogEventHook.install(in: OtherSDK.self) { _, _, _ in Issue.record("Reported a call it shouldn't wrap") }
        #expect(wrapped == 0)

        let sdk = OtherSDK()
        sdk.logEvent(7, withValues: true)
        #expect(sdk.received == [7])
    }

    @Test func appsFlyerHasBothMethodsWithTheExpectedArguments() {
        #expect(LogEventHook.method(LogEventHook.logEvent, in: AppsFlyerLib.self, argumentTypes: ["@", "@"]) != nil)
        #expect(LogEventHook.method(LogEventHook.logEventWithCompletion, in: AppsFlyerLib.self, argumentTypes: ["@", "@", "@?"]) != nil)
    }

    @Test func makesAnEventFromTheNameAndValues() {
        let event = SnitchAppsFlyer.makeEvent(
            name: "af_purchase",
            values: ["af_revenue": 9.99, 42: "number key"],
            userID: "user_8f2c",
            date: Date(timeIntervalSince1970: 100)
        )
        #expect(event.source == "AppsFlyer")
        #expect(event.name == "af_purchase")
        #expect(event.userID == "user_8f2c")
        #expect(event.date == Date(timeIntervalSince1970: 100))
        #expect(event.propertyNames == ["42", "af_revenue"])
        #expect(!event.isAutomatic)
        #expect(event.sdkPropertyCount == 0)
    }

    @Test func anEmptyUserIDIsLeftOut() {
        #expect(SnitchAppsFlyer.makeEvent(name: "af_login", values: nil, userID: "").userID == nil)
        #expect(SnitchAppsFlyer.makeEvent(name: "af_login", values: nil, userID: nil).propertyCount == 0)
    }

    @Test func startAddsTheAppsFlyerScreenWithItsLogo() {
        SnitchAppsFlyer.start()
        SnitchAppsFlyer.start()
        #expect(Snitch.events.sources.contains("AppsFlyer"))
        #expect(SnitchAppsFlyer.logo?.renderingMode == .alwaysTemplate)
        #expect(Snitch.events.icon(for: "AppsFlyer") != nil)
    }
}
