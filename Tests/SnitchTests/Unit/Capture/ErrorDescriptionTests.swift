//
//  ErrorDescriptionTests.swift
//  SnitchTests
//
//  Created by BOniani on 13/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct ErrorDescriptionTests {
    @Test func errorsIncludeDomainAndCode() {
        let text = SnitchURLProtocol.describe(URLError(.secureConnectionFailed))
        #expect(text.hasSuffix("(NSURLErrorDomain -1200)"))
    }
}
