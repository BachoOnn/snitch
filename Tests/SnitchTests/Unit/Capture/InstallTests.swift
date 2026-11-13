//
//  InstallTests.swift
//  SnitchTests
//
//  Created by BOniani on 13/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct InstallTests {
    @Test func installIsIdempotentAndFirst() {
        let configuration = URLSessionConfiguration.ephemeral
        Snitch.install(in: configuration)
        Snitch.install(in: configuration)
        let classes = configuration.protocolClasses ?? []
        #expect(classes.first is SnitchURLProtocol.Type)
        #expect(classes.filter { $0 is SnitchURLProtocol.Type }.count == 1)
    }

    @Test func eachConfigurationGetsItsOwnClass() throws {
        let first = URLSessionConfiguration.ephemeral
        let second = URLSessionConfiguration.ephemeral
        Snitch.install(in: first)
        Snitch.install(in: second)
        let a = try #require(first.protocolClasses?.first)
        let b = try #require(second.protocolClasses?.first)
        #expect(a != b)
        #expect(a is SnitchURLProtocol.Type)
        #expect(SessionProtocols.forwarder(for: a) != nil)
        #expect(SessionProtocols.forwarder(for: SnitchURLProtocol.self) == nil)
    }

    @Test func forwardingCopyDropsSnitchButKeepsTheAppsProtocols() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        Snitch.install(in: configuration)
        let copy = SessionProtocols.forwardingCopy(of: configuration)
        #expect(copy.protocolClasses?.contains { $0 is SnitchURLProtocol.Type } == false)
        #expect(copy.protocolClasses?.contains { $0 == StubURLProtocol.self } == true)
    }

    @Test func backgroundConfigurationsAreLeftAlone() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "dev.snitch.tests.background")
        let before = configuration.protocolClasses?.count
        Snitch.install(in: configuration)
        #expect(configuration.protocolClasses?.count == before)
    }
}
