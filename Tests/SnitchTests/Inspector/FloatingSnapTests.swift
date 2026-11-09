import CoreGraphics
import Testing
@testable import Snitch

struct FloatingSnapTests {
    private let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
    private let size = CGSize(width: 52, height: 52)

    @Test func snapsToTheNearestSide() {
        #expect(FloatingSnap.snap(CGPoint(x: 120, y: 300), size: size, in: bounds, margin: 16) == CGPoint(x: 42, y: 300))
        #expect(FloatingSnap.snap(CGPoint(x: 260, y: 300), size: size, in: bounds, margin: 16) == CGPoint(x: 358, y: 300))
    }

    @Test func staysInsideVertically() {
        #expect(FloatingSnap.snap(CGPoint(x: 300, y: -50), size: size, in: bounds, margin: 16).y == 42)
        #expect(FloatingSnap.snap(CGPoint(x: 300, y: 2000), size: size, in: bounds, margin: 16).y == 758)
    }

    @Test func respectsBoundsOrigin() {
        let inset = CGRect(x: 0, y: 100, width: 400, height: 600)
        #expect(FloatingSnap.snap(CGPoint(x: 10, y: 0), size: size, in: inset, margin: 8).y == 134)
    }

    @Test func defaultsToBottomTrailing() {
        #expect(FloatingSnap.bottomTrailing(size: size, in: bounds, margin: 16) == CGPoint(x: 358, y: 758))
    }
}
