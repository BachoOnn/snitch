//
//  FilterToggleCell.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct FilterToggleCell<Content: View>: View {
    let isOn: Bool
    let accessibilityLabel: String
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.tile)
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity)
                .foregroundStyle(isOn ? Theme.accent : Theme.textMuted)
                .background(isOn ? Theme.accent.opacity(0.10) : Theme.veil(0.04), in: shape)
                .overlay(shape.strokeBorder(isOn ? Theme.accent.opacity(0.45) : Theme.veil(0.08)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
