//
//  FloatingSnapTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import CoreGraphics
import Testing
@testable import Snitch

struct FloatingSnapTests {
    private let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
    private let size = CGSize(width: 52, height: 52)

    @Test func staysExactlyWhereDroppedInside() {
        let dropped = CGPoint(x: 173, y: 311)
        #expect(FloatingSnap.clamp(dropped, size: size, in: bounds, margin: 16) == dropped)
    }

    @Test func pullsBackJustInsideWhenDroppedOffScreen() {
        #expect(FloatingSnap.clamp(CGPoint(x: -30, y: 300), size: size, in: bounds, margin: 16) == CGPoint(x: 42, y: 300))
        #expect(FloatingSnap.clamp(CGPoint(x: 500, y: 2000), size: size, in: bounds, margin: 16) == CGPoint(x: 358, y: 758))
    }

    @Test func respectsBoundsOrigin() {
        let inset = CGRect(x: 0, y: 100, width: 400, height: 600)
        #expect(FloatingSnap.clamp(CGPoint(x: 200, y: 0), size: size, in: inset, margin: 8).y == 134)
    }

    @Test func defaultsToBottomTrailing() {
        #expect(FloatingSnap.bottomTrailing(size: size, in: bounds, margin: 16) == CGPoint(x: 358, y: 758))
    }
}
