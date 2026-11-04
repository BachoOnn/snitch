import Testing
@testable import Tapwire

@Test func versionIsSet() {
    #expect(!Tapwire.version.isEmpty)
}
