//
//  EventStoreTests.swift
//  SnitchTests
//
//  Created by BOniani on 15/11/2026.
//

import UIKit
import Testing
@testable import Snitch

struct EventStoreTests {
    private func event(_ name: String, source: String = "PostHog") -> AnalyticsEvent {
        AnalyticsEvent(source: source, name: name)
    }

    @Test func keepsOrderAndDropsTheOldestWhenFull() {
        let store = EventStore(maxCount: 2)
        ["a", "b", "c"].forEach { store.insert(event($0)) }
        #expect(store.events.map(\.name) == ["b", "c"])
    }

    @Test func registersEachSourceOnceInOrder() {
        let store = EventStore()
        store.register(source: "PostHog")
        store.insert(event("x", source: "Other"))
        store.register(source: "PostHog")
        #expect(store.sources == ["PostHog", "Other"])
    }

    @Test func keepsTheIconASourceRegistersWith() {
        let store = EventStore()
        store.register(source: "PostHog")
        #expect(store.icon(for: "PostHog") == nil)
        store.register(source: "PostHog", icon: UIImage(systemName: "star"))
        #expect(store.icon(for: "PostHog") != nil)
        #expect(store.sources == ["PostHog"])
    }

    @Test func clearRemovesOnlyThatSource() {
        let store = EventStore()
        store.insert(event("a"))
        store.insert(event("b", source: "Other"))
        store.clear(source: "PostHog")
        #expect(store.events.map(\.name) == ["b"])
        #expect(store.sources == ["PostHog", "Other"], "the screen stays after clearing")
    }

    @Test func changesFireRightAwayAndAfterEachChange() async {
        let store = EventStore()
        var iterator = store.changes().makeAsyncIterator()
        #expect(await iterator.next() != nil)
        store.insert(event("a"))
        #expect(await iterator.next() != nil)
        #expect(store.events.count == 1)
    }

    @Test func concurrentInsertsAreSafe() {
        let store = EventStore(maxCount: 1000)
        DispatchQueue.concurrentPerform(iterations: 500) { store.insert(event("\($0)")) }
        #expect(store.events.count == 500)
    }
}
