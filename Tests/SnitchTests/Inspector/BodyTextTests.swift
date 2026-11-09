import Testing
import UIKit
@testable import Snitch

@MainActor
@Suite struct BodyTextTests {
    private func plainLines(_ texts: [String]) -> [[BodyToken]] {
        texts.map { [BodyToken(kind: .plain, text: $0)] }
    }

    private func measured(_ text: NSAttributedString) -> CGSize {
        text.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
    }

    @Test func sizeMatchesAFullMeasurement() {
        let text = BodyText.lines(plainLines(["{", "  \"name\": \"a much longer line than the rest\",", "}"]), matches: [])
        let size = BodyText.size(of: text)
        let full = measured(text)
        #expect(size.height == 3 * BodyText.lineHeight)
        #expect(abs(size.width - full.width) <= 2)
    }

    @Test func sizeCountsEmptyAndTrailingLines() {
        #expect(BodyText.size(of: BodyText.lines(plainLines([""]), matches: [])).height == BodyText.lineHeight)
        #expect(BodyText.size(of: BodyText.lines(plainLines(["a", ""]), matches: [])).height == 2 * BodyText.lineHeight)
    }

    @Test func gutterSizeHasOneRowPerLine() {
        let gutter = BodyText.gutter(count: 120, matches: [3])
        #expect(BodyText.size(of: gutter).height == 120 * BodyText.lineHeight)
    }

    @Test func largeBodyIsQuickToMeasure() {
        let items = (0..<200).map { "{\"id\":\($0),\"name\":\"Item \($0)\",\"tags\":[\"a\",\"b\"],\"active\":true}" }
        let data = Data(("[" + items.joined(separator: ",") + "]").utf8)
        let lines = try! #require(BodyFormatter.lines(for: data, pretty: true))
        let clock = ContinuousClock()
        let elapsed = clock.measure {
            _ = BodyText.size(of: BodyText.lines(lines, matches: []))
        }
        // Measuring the whole text this way used to take seconds.
        #expect(elapsed < .milliseconds(250))
    }
}
