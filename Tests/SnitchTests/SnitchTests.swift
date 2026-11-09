import Testing
@testable import Snitch

@Test func versionIsSet() {
    #expect(!Snitch.version.isEmpty)
}
