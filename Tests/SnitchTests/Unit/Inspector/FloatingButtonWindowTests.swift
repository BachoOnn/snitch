//
//  FloatingButtonWindowTests.swift
//  SnitchTests
//
//  Created by BOniani on 11/11/2026.
//

import Testing
import UIKit
@testable import Snitch

@MainActor
struct FloatingButtonWindowTests {
    @Test func claimsOnlyTheButton() {
        let window = FloatingButtonWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
        let button = UIView(frame: CGRect(x: 100, y: 200, width: 60, height: 60))
        window.addSubview(button)
        window.button = button

        #expect(window.hitTest(CGPoint(x: 130, y: 230), with: nil) != nil)
        #expect(window.hitTest(CGPoint(x: 10, y: 10), with: nil) == nil, "touches elsewhere reach the app")
        #expect(window.hitTest(CGPoint(x: 165, y: 230), with: nil) == nil)
    }

    @Test func claimsNothingWithoutAButton() {
        let window = FloatingButtonWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
        #expect(window.hitTest(CGPoint(x: 10, y: 10), with: nil) == nil)
    }
}
