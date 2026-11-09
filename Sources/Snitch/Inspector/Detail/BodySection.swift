#if os(iOS)
import SwiftUI
import UIKit

/// A request or response body: pretty or raw, with find and line numbers.
struct BodySection: View {
    let data: Data?
    /// The full size, which can be larger than `data` when the body was truncated.
    let size: Int

    @State private var pretty = true
    @State private var query = ""
    /// The body is drawn from resolved colors, so it is rebuilt when the appearance changes.
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isJSON = data.flatMap(BodyFormatter.prettyJSON) != nil
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title(isJSON: isJSON)).sectionLabelStyle()
                Spacer()
                if isJSON { formatToggle }
            }
            content(isJSON: isJSON)
        }
    }

    private func title(isJSON: Bool) -> String {
        guard let data, !data.isEmpty else { return "Body" }
        let kind = isJSON ? "JSON" : (String(data: data, encoding: .utf8) == nil ? "Binary" : "Text")
        return "Body · \(kind) · \(NetworkEntry.format(bytes: size))"
    }

    private var formatToggle: some View {
        HStack(spacing: 0) {
            ForEach([true, false], id: \.self) { isPretty in
                Button(isPretty ? "Pretty" : "Raw") { pretty = isPretty }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(pretty == isPretty ? Theme.text : Theme.secondary)
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(pretty == isPretty ? Theme.control : .clear, in: RoundedRectangle(cornerRadius: 7))
                    .accessibilityAddTraits(pretty == isPretty ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.border))
    }

    @ViewBuilder
    private func content(isJSON: Bool) -> some View {
        if let data, !data.isEmpty {
            if let lines = BodyFormatter.lines(for: data, pretty: pretty && isJSON) {
                code(lines, truncated: size > data.count ? data.count : nil)
            } else {
                note("Binary data · \(NetworkEntry.format(bytes: size))")
            }
        } else {
            note("No body")
        }
    }

    private func code(_ lines: [[BodyToken]], truncated: Int?) -> some View {
        let matches = matchingLines(lines)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(Theme.tertiary)
                TextField("Find in body", text: $query)
                    .font(.system(size: 13))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Text("\(matches.count) lines").font(.system(size: 12)).foregroundStyle(Theme.secondary)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            Rectangle().fill(Theme.divider).frame(height: 1)

            HStack(alignment: .top, spacing: 12) {
                SelectableText(text: gutter(count: lines.count, matches: matches), wraps: false, selectable: false)
                    .id(colorScheme)
                    .frame(width: 34, alignment: .trailing)
                    .accessibilityHidden(true)
                ScrollView(.horizontal, showsIndicators: false) {
                    SelectableText(text: body(lines, matches: matches), wraps: false)
                        .id(colorScheme)
                        .padding(.trailing, 12)
                }
            }
            .padding(.vertical, 10)

            if let truncated {
                note("Showing the first \(NetworkEntry.format(bytes: truncated)) of \(NetworkEntry.format(bytes: size))")
                    .padding([.horizontal, .bottom], 12)
            }
        }
        .background(Theme.codeBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.divider))
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(Theme.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func matchingLines(_ lines: [[BodyToken]]) -> Set<Int> {
        let needle = query.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else { return [] }
        return Set(lines.indices.filter { lines[$0].map(\.text).joined().localizedCaseInsensitiveContains(needle) })
    }

    /// Every body line is exactly this tall, so the line numbers stay aligned.
    private static let lineHeight: CGFloat = 20

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

    /// The whole body as one selectable text, colored by token, with matching lines highlighted.
    private func body(_ lines: [[BodyToken]], matches: Set<Int>) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (index, tokens) in lines.enumerated() {
            let start = result.length
            for token in tokens {
                result.append(NSAttributedString(string: token.text, attributes: Self.attributes(color(for: token.kind))))
            }
            if matches.contains(index) {
                result.addAttribute(.backgroundColor, value: UIColor(Theme.accent.opacity(0.18)), range: NSRange(location: start, length: result.length - start))
            }
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: Self.attributes(Theme.text)))
            }
        }
        return result
    }

    private func gutter(count: Int, matches: Set<Int>) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for index in 0..<count {
            let color = matches.contains(index) ? Theme.accent : Theme.faint
            let line = "\(index + 1)" + (index < count - 1 ? "\n" : "")
            result.append(NSAttributedString(string: line, attributes: Self.attributes(color, alignment: .right)))
        }
        return result
    }

    private func color(for kind: BodyToken.Kind) -> Color {
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
