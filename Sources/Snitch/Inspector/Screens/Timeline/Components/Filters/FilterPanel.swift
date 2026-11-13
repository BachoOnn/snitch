//
//  FilterPanel.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct FilterPanel: View {
    @Binding var filter: EntryFilter
    let methods: [String]
    let hosts: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterSectionLabel("Status code")
            StatusCodeFilters(filter: $filter)

            FilterDivider()
            FilterSectionLabel("Result")
            ResultFilters(filter: $filter)

            FilterDivider()
            ChoiceMenu(title: "Method", options: methods, selection: filter.methods, onToggle: { filter.toggleMethod($0) })
            ChoiceMenu(title: "Host", options: hosts, selection: filter.hosts, onToggle: { filter.toggleHost($0) })

            FilterDivider()
            resetButton
        }
        .padding(.vertical, Theme.Spacing.spacing6)
        .frame(width: Theme.Size.filterPanelWidth)
        .foregroundStyle(Theme.text)
    }

    private var resetButton: some View {
        Button(role: .destructive) { filter = EntryFilter() } label: {
            HStack {
                Text("Reset filters")
                Spacer()
                Image(systemName: "arrow.counterclockwise")
            }
            .font(.system(size: 15))
            .foregroundStyle(Theme.danger)
            .padding(.horizontal, Theme.Spacing.spacing14)
            .frame(height: Theme.Size.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
