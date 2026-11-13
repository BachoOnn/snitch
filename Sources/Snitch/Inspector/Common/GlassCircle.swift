//
//  GlassCircle.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct GlassCircle: View {
    let systemImage: String
    var badge: Int = 0

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Theme.text)
            .frame(width: Theme.Size.floatingControl, height: Theme.Size.floatingControl)
            .snitchGlass(in: Circle())
            .overlay(alignment: .topTrailing) { badgeView }
            .contentShape(Circle())
    }

    @ViewBuilder
    private var badgeView: some View {
        if badge > 0 {
            Text("\(badge)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.onAccent)
                .frame(minWidth: Theme.Size.badge, minHeight: Theme.Size.badge)
                .background(Theme.accentFill, in: Capsule())
                .offset(x: -Theme.Size.badgeOffset, y: Theme.Size.badgeOffset)
        }
    }
}
