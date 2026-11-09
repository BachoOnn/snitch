#if os(iOS)
import SwiftUI
import UIKit

/// Builds the attributed text for a body and its line numbers.
/// Every line is exactly `lineHeight` tall, so the two columns stay aligned.
enum BodyText {
    static let lineHeight: CGFloat = 20

    /// The whole body as one text, colored by token, with matching lines highlighted.
    static func lines(_ lines: [[BodyToken]], matches: Set<Int>) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (index, tokens) in lines.enumerated() {
            let start = result.length
            for token in tokens {
                result.append(NSAttributedString(string: token.text, attributes: attributes(color(for: token.kind))))
            }
            if matches.contains(index) {
                let range = NSRange(location: start, length: result.length - start)
                result.addAttribute(.backgroundColor, value: UIColor(Theme.accent.opacity(0.18)), range: range)
            }
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: attributes(Theme.text)))
            }
        }
        return result
    }

    /// Right-aligned line numbers, accented where the line matches.
    static func gutter(count: Int, matches: Set<Int>) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for index in 0..<count {
            let color = matches.contains(index) ? Theme.accent : Theme.faint
            let line = "\(index + 1)" + (index < count - 1 ? "\n" : "")
            result.append(NSAttributedString(string: line, attributes: attributes(color, alignment: .right)))
        }
        return result
    }

    private static func attributes(_ color: Color, alignment: NSTextAlignment = .natural) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        paragraph.alignment = alignment
        return [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor(color),
            .paragraphStyle: paragraph,
        ]
    }

    private static func color(for kind: BodyToken.Kind) -> Color {
        switch kind {
        case .key: return Theme.jsonKey
        case .string: return Theme.jsonString
        case .number, .literal: return Theme.jsonNumber
        case .punctuation: return Theme.secondary
        case .plain: return Theme.text
        }
    }
}
#endif
