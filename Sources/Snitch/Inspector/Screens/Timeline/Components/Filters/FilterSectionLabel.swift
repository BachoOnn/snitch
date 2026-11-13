//
//  FilterSectionLabel.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct FilterSectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Theme.sectionLabel)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
            .padding(.horizontal, Theme.Spacing.spacing14)
            .padding(.top, Theme.Spacing.spacing8)
            .padding(.bottom, Theme.Spacing.spacing6)
    }
}
