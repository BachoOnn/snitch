//
//  TimelineView.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var model: InspectorModel

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
}
