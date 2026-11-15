//
//  FloatingButtonModelTests.swift
//  SnitchTests
//
//  Created by BOniani on 16/11/2026.
//

import Foundation
import Testing
@testable import Snitch

@MainActor
struct FloatingButtonModelTests {
    private func failed(_ entry: NetworkEntry) -> NetworkEntry {
        var entry = entry
        entry.duration = 0.1
        entry.error = "offline"
        return entry
    }

    private func entry(startedAgo seconds: TimeInterval = 0) -> NetworkEntry {
        NetworkEntry(url: URL(string: "https://api.snitch.test/a"), method: "GET", startDate: Date().addingTimeInterval(-seconds))
    }

    private func eventually(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<300 where !condition() {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        return condition()
    }

    @Test func showsFailuresFromBeforeTheButtonExisted() async {
        let store = NetworkStore()
        store.insert(failed(entry(startedAgo: 5)))
        let model = FloatingButtonModel(store: store)
        #expect(await eventually { model.hasNewErrors })
    }

    @Test func clearsWhenSeenAndShowsOnlyNewFailures() async {
        let store = NetworkStore()
        store.insert(failed(entry()))
        let model = FloatingButtonModel(store: store)
        #expect(await eventually { model.hasNewErrors })

        model.markSeen()
        #expect(!model.hasNewErrors)

        store.insert(entry())
        #expect(await eventually { model.activity >= 2 })
        #expect(!model.hasNewErrors, "a successful request is not an error")

        store.insert(failed(entry()))
        #expect(await eventually { model.hasNewErrors })
    }

    @Test func showsARequestThatStartedBeforeLookingButFailedAfter() async {
        let store = NetworkStore()
        let slow = entry(startedAgo: 10)
        store.insert(slow)
        let model = FloatingButtonModel(store: store)
        #expect(await eventually { model.activity == 1 })
        model.markSeen()

        store.update(failed(slow))
        #expect(await eventually { model.hasNewErrors })
    }
}
