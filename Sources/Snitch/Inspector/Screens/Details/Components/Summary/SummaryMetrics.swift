//
//  SummaryMetrics.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct SummaryMetrics: View {
    let entry: NetworkEntry

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing14) {
            Text(entry.displayDuration ?? "pending")
            separator
            Text(NetworkEntry.format(bytes: entry.responseBodySize))
            separator
            Text(entry.startDate.formatted(date: .omitted, time: .standard))
        }
        .font(Theme.mono(12))
        .foregroundStyle(Theme.textMuted)
        .padding(.top, Theme.Spacing.spacing8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Hairline(color: Theme.border) }
    }

    private var separator: some View {
        Rectangle().fill(Theme.control).frame(width: Theme.Size.hairline, height: 12)
    }
}
