//
//  EntryDetailView.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

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

    @ViewBuilder
    private func sections(_ entry: NetworkEntry) -> some View {
        HeadersSection(headers: entry.headers(on: side), onCopy: copy)
            .id(side)
            .padding(.top, Theme.Spacing.spacing8)
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
            ShareMenu(entry: entry)
        }
    }

    private var clearedNote: some View {
        Text("This request was cleared.")
            .font(.system(size: 15))
            .foregroundStyle(Theme.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

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
