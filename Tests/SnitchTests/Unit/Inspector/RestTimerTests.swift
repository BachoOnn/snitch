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

    @Test func restsOnceAfterTheDelay() async {
        let rests = Counter()
        let timer = RestTimer(delay: 0.05) { rests.value += 1 }
        timer.poke()
        #expect(rests.value == 0)
        await wait(0.2)
        #expect(rests.value == 1)
    }

    @Test func pokingPostponesTheRest() async {
        let rests = Counter()
        let timer = RestTimer(delay: 0.15) { rests.value += 1 }
        timer.poke()
        await wait(0.1)
        timer.poke()
        await wait(0.1)
        #expect(rests.value == 0, "the second poke restarts the wait")
        await wait(0.15)
        #expect(rests.value == 1)
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
        await wait(0.2)
        #expect(model.isResting)
        model.wake()
        #expect(!model.isResting)
    }

    @Test func restsAfterFiveSecondsByDefault() {
        #expect(FloatingButtonModel.restDelay == 5)
    }
}
