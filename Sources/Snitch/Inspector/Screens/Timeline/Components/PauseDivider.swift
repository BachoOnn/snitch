//
//  PauseDivider.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct PauseDivider: View {
    let pause: NetworkStore.Pause

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing12) {
            icon.onWire(dashed: true)
            label
            fadingLine
        }
        .padding(.vertical, Theme.Spacing.spacing6)
        .frame(minHeight: Theme.Size.pauseMinHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var icon: some View {
        Image(systemName: "pause.fill")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Theme.silver)
            .frame(width: Theme.Size.pauseIcon, height: Theme.Size.pauseIcon)
            .background(Theme.background)
    }

    private var label: some View {
        HStack(spacing: 0) {
            Text(pause.start.formatted(date: .omitted, time: .standard))
                .foregroundStyle(Theme.textMuted)
            Text(" · \(pause.durationText)")
                .foregroundStyle(Theme.tertiary)
        }
        .font(Theme.mono(10))
        .tracking(0.6)
        .fixedSize()
    }

    private var fadingLine: some View {
        LinearGradient(
            colors: [Theme.silver.opacity(0.45), Theme.silver.opacity(0.12), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: Theme.Size.hairline)
    }

    private var accessibilityText: String {
        pause.end == nil
            ? "Paused since \(pause.start.formatted(date: .omitted, time: .shortened)), new requests are not recorded"
            : "Paused for \(pause.durationText), requests were not recorded"
    }
}
