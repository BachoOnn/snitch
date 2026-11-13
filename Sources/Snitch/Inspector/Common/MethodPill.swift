//
//  MethodPill.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct MethodPill: View {
    let method: String
    let outcome: NetworkEntry.Outcome

    private var isPending: Bool { outcome == .pending }

    var body: some View {
        let color = Theme.color(for: outcome)
        Text(method)
            .font(Theme.mono(10, .bold))
            .tracking(0.3)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(color)
            .frame(width: Theme.Size.methodPill.width, height: Theme.Size.methodPill.height)
            .background {
                Capsule()
                    .fill(Theme.background)
                    .overlay(Capsule().fill(color.opacity(isPending ? 0 : 0.08)))
            }
            .overlay {
                Capsule().strokeBorder(
                    color.opacity(isPending ? 1 : 0.38),
                    style: StrokeStyle(lineWidth: Theme.Size.hairline, dash: isPending ? [3, 2] : [])
                )
            }
    }
}
