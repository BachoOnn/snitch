#if os(iOS)
import SwiftUI

/// One request in full: a summary card, then its request or response headers and body.
struct EntryDetailView: View {
    @ObservedObject var model: InspectorModel
    let id: UUID

    enum Side: String, CaseIterable {
        case request = "Request", response = "Response"
    }

    @State private var side: Side = .request
    @State private var summaryVisible = true
    @State private var toast: Toast?

    var body: some View {
        Group {
            if let entry = model.entry(id: id) {
                content(entry)
            } else {
                Text("This request was cleared.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .inspectorBarBackground()
        .toast($toast)
    }

    private func content(_ entry: NetworkEntry) -> some View {
        ScrollView {
            // The card stays outside the lazy stack so its position keeps being reported
            // after it scrolls out of view.
            VStack(alignment: .leading, spacing: 0) {
                SummaryCard(entry: entry)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: SummaryBottomKey.self, value: proxy.frame(in: .named(Self.space)).maxY)
                        }
                    )
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        VStack(alignment: .leading, spacing: 18) {
                            HeadersSection(headers: side == .request ? entry.requestHeaders : entry.responseHeaders)
                            BodySection(
                                data: side == .request ? entry.requestBody : entry.responseBody,
                                size: side == .request ? entry.requestBodySize : entry.responseBodySize
                            )
                        }
                        .id(side)
                        .padding(.top, 8)
                    } header: {
                        sidePicker
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .coordinateSpace(name: Self.space)
        .onPreferenceChange(SummaryBottomKey.self) { bottom in
            let visible = bottom > 0
            if visible != summaryVisible {
                withAnimation(.easeInOut(duration: 0.2)) { summaryVisible = visible }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                CompactSummary(entry: entry)
                    .opacity(summaryVisible ? 0 : 1)
                    .accessibilityHidden(summaryVisible)
            }
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: entry.curlCommand) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share as cURL")
            }
        }
        .overlay(alignment: .bottomTrailing) {
            copyButton(entry)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
        }
    }

    private var sidePicker: some View {
        HStack(spacing: 4) {
            ForEach(Side.allCases, id: \.self) { option in
                Button(option.rawValue) { side = option }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(side == option ? Color(hex: 0x06210F) : Color(hex: 0xC9D6CE))
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(side == option ? Theme.accent : .clear, in: Capsule())
                    .accessibilityAddTraits(side == option ? .isSelected : [])
            }
        }
        .padding(4)
        .tapwireGlass(in: Capsule())
        .padding(.vertical, 10)
        .background(Theme.background)
    }

    private func copyButton(_ entry: NetworkEntry) -> some View {
        Button { copyBody(of: entry) } label: {
            GlassCircle(systemImage: "doc.on.doc")
        }
        .accessibilityLabel("Copy")
        .accessibilityHint("Long press for more options")
        .contextMenu {
            Button { copyBody(of: entry) } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button {
                Clipboard.copy(entry.curlCommand)
                toast = Toast(title: "Copied as cURL")
            } label: {
                Label("Copy as cURL", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        }
    }

    private func copyBody(of entry: NetworkEntry) {
        let data = side == .request ? entry.requestBody : entry.responseBody
        guard let data, let text = BodyFormatter.copyText(for: data) else {
            toast = Toast(title: "No body to copy")
            return
        }
        Clipboard.copy(text)
        toast = Toast(title: "Copied")
    }

    private static let space = "entry-detail"
}

/// Where the summary card's bottom edge is, relative to the top of the scroll view.
private struct SummaryBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = min(value, nextValue()) }
}

/// The card at the top of the detail screen.
struct SummaryCard: View {
    let entry: NetworkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                MethodPill(method: entry.method, outcome: entry.outcome)
                Text(entry.displayStatus)
                    .font(Theme.mono(20, .bold))
                    .foregroundStyle(entry.outcome == .pending ? Theme.secondary : Theme.color(for: entry.outcome))
                if let phrase = entry.reasonPhrase, entry.outcome != .failed {
                    Text(phrase)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: 0xA9BBB0))
                }
            }
            (Text(entry.displayHost).foregroundColor(Theme.tertiary) + Text(entry.displayPath).foregroundColor(Theme.text))
                .font(Theme.mono(13))
                .textSelection(.enabled)
            if let error = entry.error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.danger)
            }
            HStack(spacing: 14) {
                Text(entry.displayDuration ?? "pending")
                separator
                Text(NetworkEntry.format(bytes: entry.responseBodySize))
                separator
                Text(entry.startDate.formatted(date: .omitted, time: .standard))
            }
            .font(Theme.mono(12))
            .foregroundStyle(Color(hex: 0xC9D6CE))
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) { Rectangle().fill(Theme.border).frame(height: 1) }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.border))
        .accessibilityElement(children: .combine)
    }

    private var separator: some View {
        Rectangle().fill(Color(hex: 0x24302A)).frame(width: 1, height: 12)
    }
}

/// The one-line summary shown in the navigation bar once the card scrolls away.
private struct CompactSummary: View {
    let entry: NetworkEntry

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Theme.color(for: entry.outcome)).frame(width: 7, height: 7)
            Text(entry.displayStatus).foregroundStyle(Theme.color(for: entry.outcome))
            Text(entry.method).foregroundStyle(Color(hex: 0xC9D6CE))
            Text(entry.displayPath).foregroundStyle(Theme.text).lineLimit(1).truncationMode(.middle)
        }
        .font(Theme.mono(13, .semibold))
        .frame(maxWidth: 240)
    }
}
#endif
