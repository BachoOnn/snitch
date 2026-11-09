import UIKit

/// A body drawn and measured once, ready to show.
///
/// Building and measuring a long body is the slow part of the detail screen, so it is
/// done only when the lines, the find text, or the appearance change.
struct BodyRender {
    let text: NSAttributedString
    let textSize: CGSize
    let gutter: NSAttributedString
    let gutterSize: CGSize
    let matchCount: Int

    init(lines: [[BodyToken]], query: String) {
        let matches = BodyFormatter.lines(matching: query, in: lines)
        text = BodyText.lines(lines, matches: matches)
        textSize = BodyText.size(of: text)
        gutter = BodyText.gutter(count: lines.count, matches: matches)
        gutterSize = BodyText.size(of: gutter)
        matchCount = matches.count
    }
}
