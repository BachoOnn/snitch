//
//  LoggerSwitcher.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

/// Rounded, equal-width tabs, one per logger, each with its logo and count.
struct LoggerSwitcher: View {
    let selection: InspectorScreen
    let screens: [InspectorScreen]
    let count: (InspectorScreen) -> Int
    let icon: (InspectorScreen) -> UIImage?
    let onSelect: (InspectorScreen) -> Void

    @Namespace private var highlight

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing2) {
            ForEach(screens, id: \.self) { screen in
                segment(screen, isSelected: screen == selection)
            }
        }
        .padding(Theme.Spacing.spacing4)
        .snitchGlass(in: Capsule())
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.bottom, Theme.Spacing.spacing8)
        .background(Theme.background)
    }

    private func segment(_ screen: InspectorScreen, isSelected: Bool) -> some View {
        Button { onSelect(screen) } label: {
            HStack(spacing: Theme.Spacing.spacing6) {
                logo(screen, isSelected: isSelected)
                Text("\(count(screen))")
                    .font(Theme.mono(12, .semibold))
                    .foregroundStyle(isSelected ? Theme.onAccent : Theme.textMuted)
                    .contentTransition(.numericText())
            }
            .frame(width: Theme.Size.switcherSegmentWidth, height: Theme.Size.switcherSegment)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.accentFill)
                        .matchedGeometryEffect(id: "highlight", in: highlight)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(screen.title), \(count(screen))")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func logo(_ screen: InspectorScreen, isSelected: Bool) -> some View {
        let tint = isSelected ? Theme.onAccent : Theme.text
        if let image = icon(screen) {
            SourceLogo(image: image, tint: tint)
                .frame(height: Theme.Size.switcherIcon)
        } else {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
        }
    }
}
