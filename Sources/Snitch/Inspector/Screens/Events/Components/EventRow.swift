//
//  EventRow.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventRow: View {
    let event: AnalyticsEvent

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing12) {
            EventDot(isAutomatic: event.isAutomatic)
                .onWire(width: Theme.Size.eventDotColumn)
            VStack(alignment: .leading, spacing: Theme.Spacing.spacing2) {
                Text(event.name)
                    .font(Theme.mono(13))
                    .foregroundStyle(event.isAutomatic ? Theme.secondary : Theme.text)
                    .lineLimit(1)
                Text(event.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Theme.Spacing.spacing8)
            Text(event.displayTime)
                .font(Theme.mono(10))
                .foregroundStyle(Theme.faint)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(event.name), \(event.subtitle), \(event.displayTime)")
    }
}
