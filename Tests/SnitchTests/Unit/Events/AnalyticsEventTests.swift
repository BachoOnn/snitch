//
//  AnalyticsEventTests.swift
//  SnitchTests
//
//  Created by BOniani on 15/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct AnalyticsEventTests {
    private func json(_ data: Data) -> String {
        String(decoding: data, as: UTF8.self)
    }

    @Test func storesPropertiesAsSortedJSON() {
        let event = AnalyticsEvent(source: "PostHog", name: "add_to_cart", properties: ["sku": "TW-2041", "qty": 2, "gift": true])
        #expect(json(event.properties) == #"{"gift":true,"qty":2,"sku":"TW-2041"}"#)
        #expect(event.propertyCount == 3)
    }

    @Test func keepsValuesJSONCantHoldAsText() {
        let url = URL(string: "https://shop.test/p/1")!
        let missing: String? = nil
        let event = AnalyticsEvent(source: "PostHog", name: "e", properties: [
            "url": url,
            "missing": missing as Any,
            "nested": ["when": Date(timeIntervalSince1970: 0), "ids": [1, 2]],
            "ratio": Double.nan,
        ])
        let decoded = JSONProperties.decode(event.properties)
        #expect(decoded["url"] as? String == "https://shop.test/p/1")
        #expect(decoded["missing"] is NSNull)
        #expect((decoded["nested"] as? [String: Any])?["when"] as? String == "1970-01-01T00:00:00Z")
        #expect(decoded["ratio"] as? String == "nan")
    }

    @Test func keepsTheSDKsPropertiesAsReadyToShowText() {
        let event = AnalyticsEvent(source: "PostHog", name: "e", properties: ["price": 1, "a": 2], sdkProperties: [
            "$os": "iOS", "$width": 402, "$wifi": true, "$tags": ["a", "b"],
        ])
        #expect(event.propertyNames == ["a", "price"])
        #expect(event.sdkProperties == ["$os": "iOS", "$width": "402", "$wifi": "true", "$tags": #"["a","b"]"#])
        #expect(event.sdkPropertyCount == 4)
    }

    @Test func subtitleListsPropertyNamesOrTheUser() {
        #expect(AnalyticsEvent(source: "P", name: "e", properties: ["b": 1, "a": 2]).subtitle == "a · b")
        #expect(AnalyticsEvent(source: "P", name: "e", userID: "user_1").subtitle == "user_1")
        #expect(AnalyticsEvent(source: "P", name: "e").subtitle == "No properties")
        #expect(AnalyticsEvent(source: "P", name: "$screen", detail: "Cart", properties: ["a": 1]).subtitle == "Cart")
    }

    @Test func searchMatchesNameUserAndPropertyValues() {
        let event = AnalyticsEvent(source: "P", name: "product_viewed", userID: "user_8f2c", properties: ["sku": "TW-2041"])
        #expect(event.matches("PRODUCT"))
        #expect(event.matches("8f2c"))
        #expect(event.matches("tw-2041"))
        #expect(!event.matches("checkout"))
        #expect(event.matches("  "))
    }

    @Test func copyTextIsTheWholeEventAsJSON() throws {
        let event = AnalyticsEvent(
            source: "P", name: "e", userID: "u", date: Date(timeIntervalSince1970: 0),
            properties: ["a": 1], sdkProperties: ["$os": "iOS"]
        )
        let object = try #require(JSONProperties.decode(Data(event.copyText.utf8)) as [String: Any]?)
        #expect(object["event"] as? String == "e")
        #expect(object["user"] as? String == "u")
        #expect(object["timestamp"] as? String == "1970-01-01T00:00:00Z")
        #expect((object["properties"] as? [String: Any])?.count == 2)
    }

    @Test func descriptionLeavesOutProperties() {
        let event = AnalyticsEvent(source: "PostHog", name: "login", properties: ["email": "secret@shop.test"])
        #expect("\(event)" == "PostHog login")
        #expect(!String(reflecting: event).contains("secret"))
    }
}
