//
//  CappedBodyTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct CappedBodyTests {
    @Test func keepsEverythingUnderTheLimit() {
        var body = CappedBody(limit: 10)
        body.append(Data("abc".utf8))
        body.append(Data("def".utf8))
        #expect(body.data == Data("abcdef".utf8))
        #expect(body.totalSize == 6)
    }

    @Test func stopsKeepingAtTheLimitButKeepsCounting() {
        var body = CappedBody(limit: 4)
        body.append(Data("abc".utf8))
        body.append(Data("defgh".utf8))
        body.append(Data("ij".utf8))
        #expect(body.data == Data("abcd".utf8))
        #expect(body.totalSize == 10)
    }
}
