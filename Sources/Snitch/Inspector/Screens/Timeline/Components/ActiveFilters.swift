//
//  ActiveFilters.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct ActiveFilters: View {
    @Binding var filter: EntryFilter

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing8) {
            header
            FlowLayout(spacing: Theme.Spacing.spacing6) {
                ForEach(filter.tokens, id: \.self) { token in
                    FilterChip(label: token.label) { filter.remove(token) }
                }
            }
        }
        .padding(.top, Theme.Spacing.spacing4)
        .padding(.bottom, Theme.Spacing.spacing16)
        .overlay(alignment: .bottom) {
            Hairline(color: Theme.veil(0.07))
        }
    }

    private var header: some View {
        HStack {
            Text("Filtered · \(filter.tokens.count)")
                .sectionLabelStyle()
                .foregroundStyle(Theme.tertiary)
            Spacer()
            Button("Clear") { filter = EntryFilter() }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondary)
        }
    }
}
