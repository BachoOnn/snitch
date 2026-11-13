//
//  CompactSummary.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct CompactSummary: View {
    let entry: NetworkEntry

    var body: some View {
        let color = Theme.color(for: entry.outcome)
        HStack(spacing: Theme.Spacing.spacing8) {
            Circle().fill(color).frame(width: Theme.Size.statusDot, height: Theme.Size.statusDot)
            Text(entry.displayStatus).foregroundStyle(color)
            Text(entry.method).foregroundStyle(Theme.textMuted)
            Text(entry.displayPath)
                .foregroundStyle(Theme.text)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(Theme.mono(13, .semibold))
        .frame(maxWidth: Theme.Size.summaryMaxWidth)
    }
}
