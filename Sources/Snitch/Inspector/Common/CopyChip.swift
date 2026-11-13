//
//  CopyChip.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct CopyChip: View {
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.chip, height: Theme.Size.chip)
                .background(Theme.veil(0.06), in: Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
