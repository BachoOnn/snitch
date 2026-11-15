//
//  EventSummaryCard.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventSummaryCard: View {
    let event: AnalyticsEvent
    let icon: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing12) {
            HStack(spacing: Theme.Spacing.spacing8) {
                source
                Spacer()
                kindTag
            }
            Text(event.name)
                .font(Theme.mono(20, .bold))
                .foregroundStyle(Theme.text)
                .lineLimit(3)
                .textSelection(.enabled)
            VStack(spacing: 0) {
                infoRow("Time", event.date.formatted(date: .abbreviated, time: .omitted) + "  " + event.displayTime)
                if let userID = event.userID {
                    Hairline()
                    infoRow("User", userID)
                }
                Hairline()
                infoRow("Properties", propertiesText)
            }
            .padding(.top, Theme.Spacing.spacing2)
        }
        .padding(Theme.Spacing.spacing14)
        .cardStyle(radius: Theme.Radius.panel)
    }

    @ViewBuilder
    private var source: some View {
        if let icon {
            SourceLogo(image: icon, tint: Theme.text)
                .frame(height: Theme.Size.sourceLogo)
                .accessibilityLabel(event.source)
        } else {
            Text(event.source)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.secondary)
        }
    }

    private var kindTag: some View {
        HStack(spacing: Theme.Spacing.spacing6) {
            EventDot(isAutomatic: event.isAutomatic)
            Text(event.isAutomatic ? "\(event.source)'s own" : "Your event")
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(event.isAutomatic ? Theme.textMuted : Theme.accent)
        .padding(.horizontal, Theme.Spacing.spacing10)
        .frame(height: Theme.Size.chip)
        .background(event.isAutomatic ? Theme.veil(0.05) : Theme.accent.opacity(0.10), in: Capsule())
    }

    private var propertiesText: String {
        let own = event.propertyCount == 1 ? "1 yours" : "\(event.propertyCount) yours"
        return event.sdkPropertyCount == 0 ? own : "\(own) · \(event.sdkPropertyCount) from \(event.source)"
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.spacing12) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.infoLabelColumn, alignment: .leading)
            Text(value)
                .font(Theme.mono(13))
                .foregroundStyle(Theme.text)
                .lineLimit(2)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Theme.Spacing.spacing8)
        .accessibilityElement(children: .combine)
    }
}
