//
//  Snitch+TestBuilds.swift
//  Snitch
//
//  Created by BOniani on 19/11/2026.
//

import Foundation

extension Snitch {
    static var enabledOutsideDebug = false

    /// Whether Snitch can run in this build.
    ///
    /// Always `true` in `DEBUG` builds. In other builds it is `false` until
    /// ``enableOutsideDebug()`` is called, and stays `false` in an app installed from
    /// the App Store.
    public static var isEnabled: Bool {
        #if DEBUG
        true
        #else
        lock.withLock { enabledOutsideDebug }
        #endif
    }

    /// Lets Snitch run in builds without `DEBUG`, such as a ReleaseTest configuration
    /// that QA installs from TestFlight.
    ///
    /// Call it before any other Snitch call, behind a compilation condition that only your
    /// test configuration sets:
    ///
    /// ```swift
    /// #if RELEASE_TEST
    /// Snitch.enableOutsideDebug()
    /// #endif
    /// Snitch.start()
    /// ```
    ///
    /// Even when called, Snitch stays off in an app installed from the App Store. It runs in
    /// TestFlight, ad hoc, enterprise and Xcode installs. Has no effect in `DEBUG` builds,
    /// where Snitch already runs.
    public static func enableOutsideDebug() {
        let allowed = !isAppStoreInstall(
            hasProvisioningProfile: Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil,
            receiptName: Bundle.main.appStoreReceiptURL?.lastPathComponent,
            isSimulator: isSimulator
        )
        lock.withLock { enabledOutsideDebug = allowed }
    }

    /// App Store installs carry no provisioning profile and a production receipt.
    /// TestFlight installs have a sandbox receipt; ad hoc, enterprise and Xcode
    /// installs have a provisioning profile.
    static func isAppStoreInstall(hasProvisioningProfile: Bool, receiptName: String?, isSimulator: Bool) -> Bool {
        !isSimulator && !hasProvisioningProfile && receiptName != "sandboxReceipt"
    }

    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }
}
