//
//  VersionTests.swift
//  SnitchTests
//
//  Created by BOniani on 09/11/2026.
//

import Testing
@testable import Snitch

@Test func versionIsSet() {
    #expect(!Snitch.version.isEmpty)
}
