import Testing
@testable import Snitch

@Suite struct ShakeDetectorTests {
    /// Feeds samples at 30 per second, alternating still and jolted readings.
    private func shake(_ detector: inout ShakeDetector, jolts: Int, from start: Double = 0, force: Double = 2.5) -> [Bool] {
        (0..<jolts * 2).map { i in
            let z = i.isMultiple(of: 2) ? force : 1.0
            return detector.record(x: 0, y: 0, z: z, at: start + Double(i) / 30)
        }
    }

    @Test func detectsThreeQuickJolts() {
        var detector = ShakeDetector()
        #expect(shake(&detector, jolts: 3) == [false, false, false, false, true, false])
    }

    @Test func ignoresHoldingStillAndGentleMovement() {
        var detector = ShakeDetector()
        #expect(!shake(&detector, jolts: 10, force: 1.5).contains(true))
    }

    @Test func countsAHeldJoltOnce() {
        var detector = ShakeDetector()
        let results = (0..<10).map { detector.record(x: 0, y: 0, z: 3, at: Double($0) / 30) }
        #expect(!results.contains(true))
    }

    @Test func ignoresJoltsTooFarApart() {
        var detector = ShakeDetector()
        let results = (0..<3).map { i in
            detector.record(x: 3, y: 0, z: 0, at: Double(i) * 2)
                || detector.record(x: 0, y: 0, z: 1, at: Double(i) * 2 + 0.1)
        }
        #expect(!results.contains(true))
    }

    @Test func waitsForTheCooldownBeforeTheNextShake() {
        var detector = ShakeDetector()
        #expect(shake(&detector, jolts: 3).contains(true))
        #expect(!shake(&detector, jolts: 3, from: 0.5).contains(true))
        #expect(shake(&detector, jolts: 3, from: 3).contains(true))
    }
}
