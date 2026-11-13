//
//  SFlowMarkTests.swift
//  SnitchTests
//
//  Created by BOniani on 11/11/2026.
//

import SwiftUI
import Testing
@testable import Snitch

struct SFlowMarkTests {
    @Test(arguments: [CGFloat(42), 120])
    func fitsInsideItsFrame(size: CGFloat) {
        let rect = CGRect(x: 10, y: 20, width: size, height: size)
        let bounds = SFlowMark().path(in: rect).boundingRect
        #expect(!bounds.isEmpty)
        #expect(rect.contains(bounds), "the mark, before stroking, stays inside its frame")
    }

    @Test func staysCenteredInAWideFrame() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 42)
        let bounds = SFlowMark().path(in: rect).boundingRect
        #expect(abs(bounds.midX - rect.midX) < 1)
    }

    @Test func lineWidthScalesWithSize() {
        #expect(SFlowMark.lineWidth(for: 42) == 3.2)
        #expect(SFlowMark.lineWidth(for: 84) == 6.4)
    }
}
