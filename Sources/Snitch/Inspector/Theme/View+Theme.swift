//
//  View+Theme.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

extension View {
    /// On earlier versions the bar is styled by `InspectorHostingController`, without a separator.
    @ViewBuilder
    func inspectorBarBackground() -> some View {
        if #available(iOS 26, *) {
            toolbarBackground(Theme.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
        }
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
