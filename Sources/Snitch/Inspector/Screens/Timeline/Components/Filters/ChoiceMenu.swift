//
//  ChoiceMenu.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct ChoiceMenu: View {
    let title: String
    let options: [String]
    let selection: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        Menu {
            if options.isEmpty {
                Text("Nothing captured yet")
            }
            ForEach(options, id: \.self) { option in
                Button { onToggle(option) } label: {
                    if selection.contains(option) {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            row
        }
    }

    private var row: some View {
        HStack(spacing: Theme.Spacing.spacing8) {
            Text(title).font(.system(size: 15))
            Spacer()
            Text(summary)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.secondary)
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, Theme.Spacing.spacing14)
        .frame(height: Theme.Size.row)
        .contentShape(Rectangle())
    }

    private var summary: String {
        selection.isEmpty ? "All" : selection.sorted().joined(separator: ", ")
    }
}
