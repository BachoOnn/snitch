//
//  DetailNote.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct DetailNote: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(Theme.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.spacing14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}
