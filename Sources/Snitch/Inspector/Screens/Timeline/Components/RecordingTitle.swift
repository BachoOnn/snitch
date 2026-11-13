//
//  RecordingTitle.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct RecordingTitle: View {
    let count: Int
    let isPaused: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.spacing2) {
            Text("SNITCH")
                .font(Theme.title)
                .tracking(2)
                .foregroundStyle(Theme.text)
            HStack(spacing: Theme.Spacing.spacing6) {
                statusDot
                Text("\(count)")
                    .font(Theme.mono(12, .semibold))
                    .foregroundStyle(isPaused ? Theme.silver : Theme.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Snitch, \(isPaused ? "paused" : "recording"), \(count) requests")
    }

    private var statusDot: some View {
        Circle()
            .fill(isPaused ? Color.clear : Theme.accent)
            .overlay(Circle().strokeBorder(Theme.silver, lineWidth: isPaused ? 1.5 : 0))
            .frame(width: Theme.Size.statusDot, height: Theme.Size.statusDot)
    }
}
