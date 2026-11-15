//
//  PendingDotsTests.swift
//  SnitchTests
//
//  Created by BOniani on 15/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct PendingDotsTests {
    private let step = PendingDots.period / Double(PendingDots.count)

    @Test func dotsLightUpInTurn() {
        for dot in 0..<PendingDots.count {
            let time = Double(dot) * step
            let brightest = (0..<PendingDots.count).max { PendingDots.opacity(dot: $0, at: time) < PendingDots.opacity(dot: $1, at: time) }
            #expect(brightest == dot)
            #expect(abs(PendingDots.opacity(dot: dot, at: time) - 1) < 0.0001)
        }
    }

    @Test func opacityStaysVisible() {
        for tick in 0..<120 {
            let time = Double(tick) * 0.01
            for dot in 0..<PendingDots.count {
                let opacity = PendingDots.opacity(dot: dot, at: time)
                #expect(opacity >= PendingDots.dimmest - 0.0001 && opacity <= 1.0001)
            }
        }
    }

    @Test func repeatsEveryPeriod() {
        #expect(abs(PendingDots.opacity(dot: 1, at: 0.3) - PendingDots.opacity(dot: 1, at: 0.3 + PendingDots.period)) < 0.0001)
    }
}
