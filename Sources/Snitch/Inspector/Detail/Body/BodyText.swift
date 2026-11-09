import SwiftUI
import UIKit

/// Builds the attributed text for a body and its line numbers.
/// Every line is exactly `lineHeight` tall, so the two columns stay aligned.
enum BodyText {
    static let lineHeight: CGFloat = 20

    /// The whole body as one text, colored by token, with matching lines highlighted.
    static func lines(_ lines: [[BodyToken]], matches: Set<Int>) -> NSAttributedString {
        // Colors are resolved once per kind, not once per token.
        var styles: [BodyToken.Kind: [NSAttributedString.Key: Any]] = [:]
        func style(_ kind: BodyToken.Kind) -> [NSAttributedString.Key: Any] {
            if let cached = styles[kind] { return cached }
            let made = attributes(color(for: kind))
            styles[kind] = made
            return made
        }
        let highlight = UIColor(Theme.accent.opacity(0.18))
        let result = NSMutableAttributedString()
        result.beginEditing()
        for (index, tokens) in lines.enumerated() {
            let start = result.length
            for token in tokens {
                result.append(NSAttributedString(string: token.text, attributes: style(token.kind)))
            }
            if matches.contains(index) {
                result.addAttribute(.backgroundColor, value: highlight, range: NSRange(location: start, length: result.length - start))
            }
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: style(.plain)))
            }
        }
        result.endEditing()
        return result
    }

    /// Right-aligned line numbers, accented where the line matches.
    static func gutter(count: Int, matches: Set<Int>) -> NSAttributedString {
        let plain = attributes(Theme.faint, alignment: .right)
        let accented = attributes(Theme.accent, alignment: .right)
        let result = NSMutableAttributedString()
        result.beginEditing()
        for index in 0..<count {
            let line = "\(index + 1)" + (index < count - 1 ? "\n" : "")
            result.append(NSAttributedString(string: line, attributes: matches.contains(index) ? accented : plain))
        }
        result.endEditing()
        return result
    }

    /// The size `text` needs without wrapping.
    ///
    /// Measuring a whole long body takes seconds, so this relies on every line being
    /// `lineHeight` tall in a monospaced font and only measures the longest line.
    static func size(of text: NSAttributedString) -> CGSize {
        let string = text.string as NSString
        var count = 0
        var longest = NSRange(location: 0, length: 0)
        string.enumerateSubstrings(
            in: NSRange(location: 0, length: string.length),
            options: [.byLines, .substringNotRequired]
        ) { _, range, _, _ in
            count += 1
            if range.length > longest.length { longest = range }
        }
        if string.length == 0 || string.hasSuffix("\n") { count += 1 }
        let width = text.attributedSubstring(from: longest).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).width
        return CGSize(width: ceil(width) + 1, height: CGFloat(count) * lineHeight)
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
