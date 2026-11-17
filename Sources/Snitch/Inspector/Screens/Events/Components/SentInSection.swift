//
//  SentInSection.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import SwiftUI

struct SentInSection: View {
    let entry: NetworkEntry
    let otherEventCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing8) {
            Text("Sent in").sectionLabelStyle()
            NavigationLink(value: entry.id) {
                row
            }
            .buttonStyle(.plain)
            .cardStyle()
        }
        .padding(.top, Theme.Spacing.section)
    }

    private var row: some View {
        HStack(spacing: Theme.Spacing.spacing12) {
            MethodPill(method: entry.method, outcome: entry.outcome)
            VStack(alignment: .leading, spacing: Theme.Spacing.spacing2) {
                Text(entry.displayPath)
                    .font(Theme.mono(13))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(entry.displayStatus)
                .font(Theme.mono(13, .semibold))
                .foregroundStyle(Theme.color(for: entry.outcome))
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.faint)
        }
        .padding(.horizontal, Theme.Spacing.spacing14)
        .padding(.vertical, Theme.Spacing.spacing12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sent in \(entry.method) \(entry.displayPath), \(detail), \(entry.displayStatus)")
    }

    private var detail: String {
        switch otherEventCount {
        case 0: return entry.displayHost
        case 1: return "\(entry.displayHost) · with 1 other event"
        default: return "\(entry.displayHost) · with \(otherEventCount) other events"
        }
    }
}
