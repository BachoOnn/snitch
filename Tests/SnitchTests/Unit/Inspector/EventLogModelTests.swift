//
//  EventLogModelTests.swift
//  SnitchTests
//
//  Created by BOniani on 15/11/2026.
//

import Foundation
import Testing
@testable import Snitch

@MainActor
struct EventLogModelTests {
    private func model(_ events: [AnalyticsEvent]) -> EventLogModel {
        let store = EventStore()
        events.forEach(store.insert)
        return EventLogModel(store: store)
    }

    private func names(_ model: EventLogModel, _ source: String = "PostHog") -> [String] {
        model.sections(from: source).flatMap(\.events).map(\.name)
    }

    private let sample = [
        AnalyticsEvent(source: "PostHog", name: "app_opened", date: Date(timeIntervalSince1970: 1)),
        AnalyticsEvent(source: "PostHog", name: "$screen", date: Date(timeIntervalSince1970: 2), isAutomatic: true),
        AnalyticsEvent(source: "PostHog", name: "add_to_cart", date: Date(timeIntervalSince1970: 3), properties: ["sku": "TW-1"]),
        AnalyticsEvent(source: "Other", name: "other_event", date: Date(timeIntervalSince1970: 4)),
    ]

    @Test func hidesTheSDKsOwnEventsByDefault() {
        let model = model(sample)
        #expect(names(model) == ["add_to_cart", "app_opened"])
        #expect(model.automaticCount(from: "PostHog") == 1)
        model.showsAutomatic = true
        #expect(names(model) == ["add_to_cart", "$screen", "app_opened"])
    }

    @Test func filtersCountChangesFromTheDefaultAndReset() {
        let model = model(sample)
        #expect(model.activeFilterCount == 0)
        model.showsAppEvents = false
        model.showsAutomatic = true
        #expect(names(model) == ["$screen"])
        #expect(model.activeFilterCount == 2)
        model.resetFilters()
        #expect(model.activeFilterCount == 0)
        #expect(names(model) == ["add_to_cart", "app_opened"])
    }

    @Test func marksPausesBetweenEventsLikeTheNetworkScreen() {
        let model = model(sample)
        let stale = NetworkStore.Pause(id: UUID(), start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 0.5))
        let gap = NetworkStore.Pause(id: UUID(), start: Date(timeIntervalSince1970: 2.5), end: Date(timeIntervalSince1970: 2.8))
        let items = model.sections(from: "PostHog", pauses: [stale, gap]).flatMap(\.items)
        #expect(items.map(\.id) == [sample[2].id, gap.id, sample[0].id], "the pause from before the oldest event is left out")

        model.search = "add"
        #expect(model.sections(from: "PostHog", pauses: [gap]).flatMap(\.items).count == 1, "searching hides pauses")
    }

    @Test func showsOneSourcePerScreen() {
        let model = model(sample)
        #expect(names(model, "Other") == ["other_event"])
        #expect(model.events(from: "PostHog").count == 3)
    }

    @Test func searchFiltersByNameAndProperties() {
        let model = model(sample)
        model.search = "tw-1"
        #expect(names(model) == ["add_to_cart"])
    }

    @Test func groupsEventsByDay() {
        let calendar = Calendar(identifier: .gregorian)
        let day: TimeInterval = 86_400
        let model = model([
            AnalyticsEvent(source: "PostHog", name: "a", date: Date(timeIntervalSince1970: day * 10)),
            AnalyticsEvent(source: "PostHog", name: "b", date: Date(timeIntervalSince1970: day * 11)),
        ])
        #expect(model.sections(from: "PostHog", calendar: calendar).count == 2)
    }

    @Test func screensListNetworkFirst() {
        #expect(InspectorScreen.available(sources: ["PostHog"]) == [.network, .events("PostHog")])
        #expect(InspectorScreen.events("PostHog").title == "PostHog")
    }
}
