//
//  EventTimelineView.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventTimelineView: View {
    @ObservedObject var events: EventLogModel
    @ObservedObject var network: InspectorModel
    let source: String

    @State private var toast: Toast?

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.bottom, Theme.Spacing.floatingClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { EventBottomBar(events: events, source: source) }
        .toast($toast)
    }

    private var content: some View {
        let sections = events.sections(from: source, pauses: network.pauses)
        return LazyVStack(alignment: .leading, spacing: 0) {
            if sections.allSatisfy(\.events.isEmpty) {
                EmptyTimeline(
                    isFiltered: !events.events(from: source).isEmpty,
                    noun: "events",
                    emptyIcon: "chart.bar",
                    emptyMessage: "Events your app sends to \(source) will show up here."
                )
            }
            ForEach(sections) { section in
                Text(Timeline.title(for: section.day))
                    .sectionLabelStyle()
                    .padding(.vertical, Theme.Spacing.spacing8)
                ForEach(section.items) { item in
                    switch item {
                    case .event(let event):
                        row(event)
                    case .pause(let pause):
                        PauseDivider(pause: pause, wireWidth: Theme.Size.eventDotColumn, noun: "events")
                    }
                }
            }
        }
    }

    private func row(_ event: AnalyticsEvent) -> some View {
        NavigationLink(value: EventRoute(id: event.id)) {
            EventRow(event: event)
                .background(Theme.background)
        }
        .buttonStyle(.plain)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.Radius.card))
        .contextMenu {
            Button {
                Clipboard.copy(event.copyText)
                toast = Toast(title: "Copied", detail: event.name)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }
}
