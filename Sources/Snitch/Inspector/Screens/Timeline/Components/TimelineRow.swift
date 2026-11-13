//
//  TimelineRow.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

struct TimelineRow: View {
    let entry: NetworkEntry

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing12) {
            MethodPill(method: entry.method, outcome: entry.outcome)
                .onWire()
            endpoint
            status
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var endpoint: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing2) {
            Text(entry.displayPath)
                .font(Theme.mono(13))
                .foregroundStyle(Theme.text)
                .lineLimit(2)
            Text(entry.displayHost)
                .font(.system(size: 11))
                .foregroundStyle(Theme.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Theme.Spacing.spacing8)
    }

    private var status: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.spacing2) {
            Text(entry.displayStatus)
                .font(Theme.mono(13, .semibold))
                .foregroundStyle(entry.outcome == .pending ? Theme.secondary : Theme.color(for: entry.outcome))
            if let duration = entry.displayDuration {
                Text(duration)
                    .font(Theme.mono(10))
                    .foregroundStyle(entry.isSlow ? Theme.warning : Theme.faint)
            }
        }
    }

    private var accessibilityText: String {
        var parts = [entry.method, entry.displayPath, entry.displayHost, outcomeText]
        if let duration = entry.displayDuration { parts.append(duration) }
        return parts.joined(separator: ", ")
    }

    private var outcomeText: String {
        switch entry.outcome {
        case .pending: return "pending"
        case .failed: return "failed"
        default: return [entry.displayStatus, entry.reasonPhrase].compactMap { $0 }.joined(separator: " ")
        }
    }
}
