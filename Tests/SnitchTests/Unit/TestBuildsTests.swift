//
//  TestBuildsTests.swift
//  SnitchTests
//
//  Created by BOniani on 19/11/2026.
//

import Testing
@testable import Snitch

@Suite struct TestBuildsTests {
    @Test func appStoreInstallHasNoProfileAndAProductionReceipt() {
        #expect(Snitch.isAppStoreInstall(hasProvisioningProfile: false, receiptName: "receipt", isSimulator: false))
    }

    @Test func appStoreInstallWithoutAReceiptYetCountsAsAppStore() {
        #expect(Snitch.isAppStoreInstall(hasProvisioningProfile: false, receiptName: nil, isSimulator: false))
    }

    @Test func testFlightInstallHasASandboxReceipt() {
        #expect(!Snitch.isAppStoreInstall(hasProvisioningProfile: false, receiptName: "sandboxReceipt", isSimulator: false))
    }

    @Test func adHocEnterpriseAndXcodeInstallsHaveAProfile() {
        #expect(!Snitch.isAppStoreInstall(hasProvisioningProfile: true, receiptName: "receipt", isSimulator: false))
    }

    @Test func simulatorIsNeverTheAppStore() {
        #expect(!Snitch.isAppStoreInstall(hasProvisioningProfile: false, receiptName: "receipt", isSimulator: true))
    }

    @Test func debugBuildsAreAlwaysEnabled() {
        #expect(Snitch.isEnabled)
        Snitch.enableOutsideDebug()
        #expect(Snitch.isEnabled)
    }
}
