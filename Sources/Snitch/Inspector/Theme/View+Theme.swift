//
//  View+Theme.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

extension View {
    func inspectorBarBackground() -> some View {
        toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    func cardStyle(
        radius: CGFloat = Theme.Radius.card,
        fill: Color = Theme.surface,
        stroke: Color = Theme.border
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        return background(fill, in: shape).overlay(shape.strokeBorder(stroke))
    }

    func sectionLabelStyle() -> some View {
        font(Theme.sectionLabel)
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
    }
}
