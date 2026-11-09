#if os(iOS)
import SwiftUI

/// One timeline item: a request that opens its detail and can be copied with a
/// long press, or a pause gap.
struct TimelineItemView: View {
    let item: TimelineItem
    @Binding var toast: Toast?

    var body: some View {
        switch item {
        case .entry(let entry):
            entryRow(entry)
        case .pause(let pause):
            PauseDivider(pause: pause)
        }
    }

    private func entryRow(_ entry: NetworkEntry) -> some View {
        NavigationLink(value: entry.id) {
            TimelineRow(entry: entry)
                .background(Theme.background)
        }
        .buttonStyle(.plain)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.Radius.card))
        .contextMenu {
            Button { copySummary(of: entry) } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }

    private func copySummary(of entry: NetworkEntry) {
        Clipboard.copy(entry.summary)
        toast = Toast(title: "Copied", detail: "\(entry.method) \(entry.displayPath)")
    }
}
#endif
