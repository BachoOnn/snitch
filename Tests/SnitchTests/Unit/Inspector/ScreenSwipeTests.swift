//
//  ScreenSwipeTests.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import CoreGraphics
import Testing
@testable import Snitch

struct ScreenSwipeTests {
    private let screens = InspectorScreen.available(sources: ["PostHog"])

    private func target(
        from current: InspectorScreen,
        in screens: [InspectorScreen]? = nil,
        _ dx: CGFloat,
        _ dy: CGFloat = 0,
        speed: CGFloat = 0
    ) -> InspectorScreen? {
        ScreenSwipe.target(
            from: current,
            in: screens ?? self.screens,
            translation: CGPoint(x: dx, y: dy),
            velocity: CGPoint(x: speed, y: 0)
        )
    }

    @Test func swipingLeftMovesToTheNextScreen() {
        #expect(target(from: .network, -80) == .events("PostHog"))
    }

    @Test func swipingRightMovesToThePreviousScreen() {
        #expect(target(from: .events("PostHog"), 80) == .network)
    }

    @Test func swipingPastTheEndsDoesNothing() {
        #expect(target(from: .network, 80) == nil)
        #expect(target(from: .events("PostHog"), -80) == nil)
    }

    @Test func shortSlowDragsDoNothing() {
        #expect(target(from: .network, -40, speed: -100) == nil)
    }

    @Test func aQuickFlickCountsEvenWhenShort() {
        #expect(target(from: .network, -30, speed: -800) == .events("PostHog"))
    }

    @Test func aFlickBackTheOtherWayDoesNothing() {
        #expect(target(from: .network, -30, speed: 800) == nil)
    }

    @Test func mostlyVerticalDragsKeepScrolling() {
        #expect(target(from: .network, -80, 60) == nil)
    }

    @Test func withOneScreenThereIsNothingToSwitchTo() {
        #expect(target(from: .network, in: InspectorScreen.available(sources: []), -80) == nil)
    }
}
