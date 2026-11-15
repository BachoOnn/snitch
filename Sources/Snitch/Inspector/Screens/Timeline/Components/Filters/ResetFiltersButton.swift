//
//  ResetFiltersButton.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct ResetFiltersButton: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Text("Reset filters")
                Spacer()
                Image(systemName: "arrow.counterclockwise")
            }
            .font(.system(size: 15))
            .foregroundStyle(Theme.danger)
            .padding(.horizontal, Theme.Spacing.spacing14)
            .frame(height: Theme.Size.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
