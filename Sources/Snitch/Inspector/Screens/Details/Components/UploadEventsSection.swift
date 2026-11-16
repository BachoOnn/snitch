//
//  UploadEventsSection.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import SwiftUI

/// Lists the analytics events a captured request uploaded, each linking to its detail.
struct UploadEventsSection: View {
    let events: [AnalyticsEvent]

    @State private var showsAll = false

    private static let collapsedCount = 5

    var body: some View {
        let shown = showsAll ? events : Array(events.prefix(Self.collapsedCount))

        VStack(alignment: .leading, spacing: Theme.Spacing.spacing8) {
            Text(title).sectionLabelStyle()
            VStack(spacing: 0) {
                ForEach(Array(shown.enumerated()), id: \.element.id) { index, event in
                    if index > 0 { Hairline() }
                    NavigationLink(value: EventRoute(id: event.id)) {
                        row(event)
                    }
                    .buttonStyle(.plain)
                }
                if events.count > Self.collapsedCount {
                    Hairline()
                    showAllButton
                }
            }
            .cardStyle()
        }
        .padding(.top, Theme.Spacing.section)
    }

    private var title: String {
        let source = events.first?.source ?? "Analytics"
        return "\(source) upload · \(events.count) \(events.count == 1 ? "event" : "events")"
    }

    private func row(_ event: AnalyticsEvent) -> some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            EventDot(isAutomatic: event.isAutomatic)
            Text(event.name)
                .font(Theme.mono(13))
                .foregroundStyle(event.isAutomatic ? Theme.secondary : Theme.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(event.displayTime)
                .font(Theme.mono(10))
                .foregroundStyle(Theme.faint)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.faint)
        }
        .padding(.horizontal, Theme.Spacing.spacing14)
        .frame(minHeight: Theme.Size.row)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(event.name), \(event.displayTime)")
    }

    private var showAllButton: some View {
        Button(showsAll ? "Show fewer" : "Show all \(events.count) events") {
            withAnimation(.easeInOut(duration: 0.2)) { showsAll.toggle() }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(Theme.accent)
        .frame(maxWidth: .infinity, minHeight: Theme.Size.row)
    }
}
