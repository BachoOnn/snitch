//
//  BodyFormatToggle.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct BodyFormatToggle: View {
    @Binding var pretty: Bool

    var body: some View {
        HStack(spacing: 0) {
            option("Pretty", isPretty: true)
            option("Raw", isPretty: false)
        }
        .padding(Theme.Spacing.spacing2)
        .cardStyle(radius: Theme.Radius.segment)
    }

    private func option(_ title: String, isPretty: Bool) -> some View {
        let isSelected = pretty == isPretty
        return Button(title) { pretty = isPretty }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? Theme.text : Theme.secondary)
            .padding(.horizontal, Theme.Spacing.spacing10)
            .frame(height: Theme.Size.toggleHeight)
            .background(isSelected ? Theme.control : .clear, in: RoundedRectangle(cornerRadius: Theme.Radius.toggle))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
