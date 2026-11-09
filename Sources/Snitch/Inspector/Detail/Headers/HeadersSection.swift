#if os(iOS)
import SwiftUI

/// A request's or response's headers. Shows the first few, hides sensitive values.
struct HeadersSection: View {
    let headers: [String: String]
    /// Copies text and shows a confirmation.
    var onCopy: (_ text: String, _ confirmation: String) -> Void = { _, _ in }

    @State private var showsAll = false

    private static let collapsedCount = 4

    var body: some View {
        let all = SensitiveHeaders.sorted(headers)
        let shown = showsAll ? all : Array(all.prefix(Self.collapsedCount))

        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Headers · \(all.count)").sectionLabelStyle()
            VStack(spacing: 0) {
                if all.isEmpty {
                    DetailNote("No headers")
                }
                ForEach(Array(shown.enumerated()), id: \.element.name) { index, header in
                    if index > 0 { Hairline() }
                    HeaderRow(name: header.name, value: header.value, expanded: showsAll, onCopy: onCopy)
                }
                if all.count > Self.collapsedCount {
                    Hairline()
                    showAllButton(count: all.count)
                }
            }
            .cardStyle()
        }
    }

    private func showAllButton(count: Int) -> some View {
        Button(showsAll ? "Show fewer" : "Show all \(count) headers") {
            withAnimation(.easeInOut(duration: 0.2)) { showsAll.toggle() }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(Theme.accent)
        .frame(maxWidth: .infinity, minHeight: Theme.Size.row)
    }
}
#endif
