//
//  PendingDots.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct PendingDots: View {
    var dotSize: CGFloat = Theme.Size.pendingDot
    var color: Color = Theme.secondary
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static let count = 3
    static let period: TimeInterval = 1.2
    static let dimmest = 0.25

    var body: some View {
        SwiftUI.TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: dotSize * 0.75) {
                ForEach(0..<Self.count, id: \.self) { dot in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .opacity(reduceMotion ? 1 : Self.opacity(dot: dot, at: time))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pending")
    }

    static func opacity(dot: Int, at time: TimeInterval) -> Double {
        let phase = time / period - Double(dot) / Double(count)
        let wave = (1 + cos(2 * .pi * phase)) / 2
        return dimmest + (1 - dimmest) * wave
    }
}
