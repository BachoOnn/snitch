#if os(iOS)
import SwiftUI

/// A request's or response's headers. Shows the first few, hides sensitive values.
struct HeadersSection: View {
    let headers: [String: String]

    @State private var showsAll = false
    @State private var revealed: Set<String> = []

    private static let collapsedCount = 4

    var body: some View {
        let all = SensitiveHeaders.sorted(headers)
        let shown = showsAll ? all : Array(all.prefix(Self.collapsedCount))

        VStack(alignment: .leading, spacing: 8) {
            Text("Headers · \(all.count)").sectionLabelStyle()
            VStack(spacing: 0) {
                if all.isEmpty {
                    Text("No headers")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                }
                ForEach(shown, id: \.name) { header in
                    row(header.name, header.value)
                    Rectangle().fill(Color(hex: 0x1A221E)).frame(height: 1)
                }
                if all.count > Self.collapsedCount {
                    Button(showsAll ? "Show fewer" : "Show all \(all.count) headers") {
                        withAnimation(.easeInOut(duration: 0.2)) { showsAll.toggle() }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity, minHeight: 40)
                }
            }
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.border))
        }
    }

    private func row(_ name: String, _ value: String) -> some View {
        let hidden = SensitiveHeaders.contains(name) && !revealed.contains(name)
        return HStack(spacing: 12) {
            Text(name)
                .foregroundStyle(Theme.secondary)
                .frame(width: 112, alignment: .leading)
                .lineLimit(1)
            Text(hidden ? "••••••••••••" : value)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(showsAll ? nil : 1)
                .textSelection(.enabled)
            if SensitiveHeaders.contains(name) {
                Button {
                    if hidden { revealed.insert(name) } else { revealed.remove(name) }
                } label: {
                    Image(systemName: hidden ? "eye" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondary)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel(hidden ? "Show \(name)" : "Hide \(name)")
            }
        }
        .font(Theme.mono(12, .regular))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
#endif
