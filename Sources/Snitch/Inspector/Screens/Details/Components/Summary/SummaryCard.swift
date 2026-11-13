//
//  SummaryCard.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct SummaryCard: View {
    let entry: NetworkEntry
    let onCopy: (_ text: String, _ confirmation: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing10) {
            status
            EndpointRow(entry: entry) {
                onCopy(entry.url?.absoluteString ?? "", "URL copied")
            }
            if let error = entry.error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.danger)
            }
            SummaryMetrics(entry: entry)
        }
        .padding(Theme.Spacing.spacing14)
        .cardStyle(radius: Theme.Radius.panel)
        .accessibilityElement(children: .contain)
    }

    private var status: some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            MethodPill(method: entry.method, outcome: entry.outcome)
            Text(entry.displayStatus)
                .font(Theme.mono(20, .bold))
                .foregroundStyle(entry.outcome == .pending ? Theme.secondary : Theme.color(for: entry.outcome))
            if let phrase = entry.reasonPhrase, entry.outcome != .failed {
                Text(phrase)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondary)
            }
        }
    }
}
