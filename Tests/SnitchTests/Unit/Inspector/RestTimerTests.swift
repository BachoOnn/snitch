//
//  RestTimerTests.swift
//  SnitchTests
//
//  Created by BOniani on 13/11/2026.
//

import Foundation
import Testing
@testable import Snitch

@MainActor
@Suite struct RestTimerTests {
    private final class Counter { var value = 0 }

    private func wait(_ seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    /// Polls instead of sleeping a fixed time, so a busy machine can't make the test flaky.
    private func eventually(_ condition: () -> Bool, timeout: Double = 3) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            await wait(0.01)
        }
        return condition()
    }

    @Test func restsOnceAfterTheDelay() async {
        let rests = Counter()
        let timer = RestTimer(delay: 0.05) { rests.value += 1 }
        timer.poke()
        #expect(rests.value == 0)
        #expect(await eventually { rests.value == 1 })
        await wait(0.2)
        #expect(rests.value == 1)
    }

    @Test func pokingPostponesTheRest() async {
        let rests = Counter()
        let timer = RestTimer(delay: 0.6) { rests.value += 1 }
        timer.poke()
        await wait(0.1)
        timer.poke()
        await wait(0.2)
        #expect(rests.value == 0, "the second poke restarts the wait")
        #expect(await eventually { rests.value == 1 })
    }

    @Test func cancelStopsTheRest() async {
        let rests = Counter()
        let timer = RestTimer(delay: 0.05) { rests.value += 1 }
        timer.poke()
        timer.cancel()
        await wait(0.15)
        #expect(rests.value == 0)
    }

    @Test func buttonFadesWhenLeftAloneAndWakesOnTouch() async {
        let model = FloatingButtonModel(restDelay: 0.05)
        model.wake()
        #expect(!model.isResting)
        #expect(await eventually { model.isResting })
        model.wake()
        #expect(!model.isResting)
    }

    @Test func restsAfterFiveSecondsByDefault() {
        #expect(FloatingButtonModel.restDelay == 5)
    }
}
