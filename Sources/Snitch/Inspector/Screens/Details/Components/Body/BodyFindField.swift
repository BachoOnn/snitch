//
//  BodyFindField.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct BodyFindField: View {
    @Binding var query: String
    let matchCount: Int
    var placeholder = "Find in body"

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Theme.tertiary)
            TextField(placeholder, text: $query)
                .font(.system(size: 13))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Text(matchCount == 1 ? "1 line" : "\(matchCount) lines")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.spacing12)
        .frame(height: Theme.Size.field)
    }
}
