import SwiftUI

/// One request in full: a summary card, then its request or response headers and body.
struct EntryDetailView: View {
    @ObservedObject var model: InspectorModel
    let id: UUID

    @State private var side: EntrySide = .request
    @State private var summaryVisible = true
    @State private var toast: Toast?

    var body: some View {
        Group {
            if let entry = model.entry(id: id) {
                content(entry)
            } else {
                clearedNote
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
                SummaryCard(entry: entry, onCopy: copy)
                    .reportsSummaryBottom(in: Self.space)
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        sections(entry)
                    } header: {
                        SidePicker(selection: $side)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.bottom, Theme.Spacing.floatingClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .coordinateSpace(name: Self.space)
        .onPreferenceChange(SummaryBottomKey.self, perform: updateSummaryVisibility)
        .toolbar { toolbar(entry) }
        .overlay {
            DetailCopyButton(
                onCopy: { copy(entry.reportText, confirmation: "Request and response copied") },
                onCopyAsCurl: { copy(entry.curlCommand, confirmation: "Copied as cURL") }
            )
        }
    }

    /// The headers and body as separate views, so the lazy stack only builds the body
    /// rows that are on screen.
    @ViewBuilder
    private func sections(_ entry: NetworkEntry) -> some View {
        HeadersSection(headers: entry.headers(on: side), onCopy: copy)
            // Fresh state, such as an expanded list, for each side.
            .id(side)
            .padding(.top, Theme.Spacing.s)
        BodySection(
            data: entry.body(on: side),
            size: entry.bodySize(on: side),
            owner: "\(entry.id)-\(side.rawValue)",
            onCopy: copy
        )
    }

    @ToolbarContentBuilder
    private func toolbar(_ entry: NetworkEntry) -> some ToolbarContent {
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

    private var clearedNote: some View {
        Text("This request was cleared.")
            .font(.system(size: 15))
            .foregroundStyle(Theme.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Shows the compact summary in the bar once the card has scrolled away.
    private func updateSummaryVisibility(bottom: CGFloat) {
        let visible = bottom > 0
        guard visible != summaryVisible else { return }
        withAnimation(.easeInOut(duration: 0.2)) { summaryVisible = visible }
    }

    private func copy(_ text: String, confirmation: String) {
        Clipboard.copy(text)
        toast = Toast(title: confirmation)
    }

    private static let space = "entry-detail"
}
