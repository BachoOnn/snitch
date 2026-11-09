#if os(iOS)
import SwiftUI

/// A request or response body: pretty or raw, with find and line numbers.
struct BodySection: View {
    let data: Data?
    /// The full size, which can be larger than `data` when the body was truncated.
    let size: Int

    @State private var pretty = true
    @State private var query = ""

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
                    .background(pretty == isPretty ? Color(hex: 0x24302A) : .clear, in: RoundedRectangle(cornerRadius: 7))
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
            Rectangle().fill(Color(hex: 0x1A221E)).frame(height: 1)

            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(lines.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 0) {
                        Text("\(index + 1)")
                            .foregroundStyle(Color(hex: 0x4E5F55))
                            .frame(width: 34, alignment: .trailing)
                            .padding(.trailing, 12)
                        Text(attributed(lines[index]))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(Theme.mono(12, .regular))
                    .padding(.vertical, 2)
                    .background(matches.contains(index) ? Theme.accent.opacity(0.10) : .clear)
                }
            }
            .padding(.vertical, 8)
            .textSelection(.enabled)

            if let truncated {
                note("Showing the first \(NetworkEntry.format(bytes: truncated)) of \(NetworkEntry.format(bytes: size))")
                    .padding([.horizontal, .bottom], 12)
            }
        }
        .background(Color(hex: 0x0F1411), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: 0x1A221E)))
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

    private func attributed(_ tokens: [BodyToken]) -> AttributedString {
        tokens.reduce(into: AttributedString()) { result, token in
            var piece = AttributedString(token.text)
            piece.foregroundColor = color(for: token.kind)
            result += piece
        }
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
