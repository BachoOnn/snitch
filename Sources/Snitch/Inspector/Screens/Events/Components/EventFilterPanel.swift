//
//  EventFilterPanel.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventFilterPanel: View {
    @ObservedObject var events: EventLogModel
    let source: String

    var body: some View {
        let all = events.events(from: source)
        let automatic = events.automaticCount(from: source)

        VStack(alignment: .leading, spacing: 0) {
            FilterSectionLabel("Show")
            VStack(spacing: Theme.Spacing.spacing6) {
                FilterToggleCell(isOn: events.showsAppEvents, accessibilityLabel: "Your events", action: {
                    events.showsAppEvents.toggle()
                }) {
                    label("Your events", count: all.count - automatic, dot: Circle().fill(Theme.accent))
                }
                FilterToggleCell(isOn: events.showsAutomatic, accessibilityLabel: "\(source)'s own events", action: {
                    events.showsAutomatic.toggle()
                }) {
                    label("\(source)'s own", count: automatic, dot: Circle().strokeBorder(Theme.silver, lineWidth: 1.5))
                }
            }
            .padding(.horizontal, Theme.Spacing.spacing10)

            FilterDivider()
            ResetFiltersButton(action: events.resetFilters)
        }
        .padding(.vertical, Theme.Spacing.spacing6)
        .frame(width: Theme.Size.filterPanelWidth)
        .foregroundStyle(Theme.text)
    }

    private func label<Dot: View>(_ text: String, count: Int, dot: Dot) -> some View {
        HStack(spacing: Theme.Spacing.spacing8) {
            dot.frame(width: Theme.Size.statusDot, height: Theme.Size.statusDot)
            Text(text).font(.system(size: 13, weight: .semibold))
            Spacer()
            Text("\(count)").font(Theme.mono(12))
        }
        .padding(.horizontal, Theme.Spacing.spacing12)
        .frame(height: Theme.Size.field)
    }
}
