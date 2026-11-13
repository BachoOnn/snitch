//
//  TimelineView.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var model: InspectorModel
    let onClose: () -> Void

    @State private var toast: Toast?

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.bottom, Theme.Spacing.floatingClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { TimelineBottomBar(model: model) }
        .navigationBarTitleDisplayMode(.inline)
        .inspectorBarBackground()
        .toolbar { toolbar }
        .navigationDestination(for: UUID.self) { id in
            EntryDetailView(model: model, id: id)
        }
        .toast($toast)
    }

    private var content: some View {
        let sections = model.sections
        return LazyVStack(alignment: .leading, spacing: 0) {
            if !model.filter.isEmpty {
                ActiveFilters(filter: $model.filter)
                    .padding(.bottom, Theme.Spacing.spacing12)
            }
            if sections.isEmpty {
                EmptyTimeline(isFiltered: !model.filter.isEmpty || !model.search.isEmpty)
            }
            ForEach(sections) { section in
                Text(Timeline.title(for: section.day))
                    .sectionLabelStyle()
                    .padding(.vertical, Theme.Spacing.spacing8)
                ForEach(section.items) { item in
                    TimelineItemView(item: item, toast: $toast)
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }
        ToolbarItem(placement: .principal) {
            RecordingTitle(count: model.entries.count, isPaused: model.isPaused)
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: model.togglePause) {
                Image(systemName: model.isPaused ? "play.fill" : "pause.fill")
            }
            .accessibilityLabel(model.isPaused ? "Resume recording" : "Pause recording")
            ClearButton(
                count: model.entries.count,
                isEnabled: !model.entries.isEmpty || !model.pauses.isEmpty,
                onClear: model.clear
            )
        }
    }
}
