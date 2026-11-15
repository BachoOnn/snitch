//
//  SnitchPostHogTests.swift
//  SnitchPostHogTests
//
//  Created by BOniani on 15/11/2026.
//

import Foundation
import Testing
@testable import Snitch
@testable import SnitchPostHog

struct SnitchPostHogTests {
    private func make(_ name: String, properties: [String: Any] = [:], distinctId: String = "user_8f2c") -> AnalyticsEvent? {
        SnitchPostHog.makeEvent(
            name: name,
            distinctId: distinctId,
            properties: properties,
            timestamp: Date(timeIntervalSince1970: 100),
            uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )
    }

    @Test func splitsTheAppsPropertiesFromPostHogs() throws {
        let event = try #require(make("product_viewed", properties: ["price": 129, "$os": "iOS", "$lib": "posthog-ios"]))
        #expect(event.source == "PostHog")
        #expect(event.propertyCount == 1)
        #expect(event.sdkPropertyCount == 2)
        #expect(String(decoding: event.properties, as: UTF8.self) == #"{"price":129}"#)
        #expect(!event.isAutomatic)
    }

    @Test func keepsPostHogsIdentityAndTime() throws {
        let event = try #require(make("add_to_cart"))
        #expect(event.userID == "user_8f2c")
        #expect(event.date == Date(timeIntervalSince1970: 100))
        #expect(event.id.uuidString == "00000000-0000-0000-0000-000000000001")
        #expect(make("add_to_cart", distinctId: "")?.userID == nil)
    }

    @Test(arguments: ["$screen", "$identify", "$autocapture", "Application Opened", "Deep Link Opened"])
    func marksPostHogsOwnEvents(name: String) {
        #expect(make(name)?.isAutomatic == true)
    }

    @Test func leavesOutSessionReplayFrames() {
        #expect(make("$snapshot") == nil)
    }

    @Test func screenViewsShowTheScreenName() {
        #expect(make("$screen", properties: ["$screen_name": "ProductDetail"])?.subtitle == "ProductDetail")
        #expect(make("add_to_cart", properties: ["$screen_name": "Cart"])?.detail == nil)
    }

    @Test func dropsScreenViewsOfSnitchsFloatingButton() {
        #expect(SnitchPostHog.isSnitchScreenView(name: "$screen", properties: ["$screen_name": "FloatingDot"]))
        #expect(!SnitchPostHog.isSnitchScreenView(name: "$screen", properties: ["$screen_name": "ProductDetail"]))
        #expect(!SnitchPostHog.isSnitchScreenView(name: "add_to_cart", properties: ["$screen_name": "FloatingDot"]))
    }

    @Test func readingTheHookAddsThePostHogScreenWithItsLogo() {
        _ = SnitchPostHog.beforeSend
        #expect(Snitch.events.sources.contains("PostHog"))
        #expect(SnitchPostHog.logo != nil)
        #expect(Snitch.events.icon(for: "PostHog") != nil)
    }
}
