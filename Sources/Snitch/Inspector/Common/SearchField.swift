//
//  SearchField.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.secondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundStyle(Theme.text)
        }
        .font(.system(size: 16))
        .padding(.horizontal, Theme.Spacing.spacing16)
        .frame(height: Theme.Size.floatingControl)
        .snitchGlass(in: Capsule())
    }
}
