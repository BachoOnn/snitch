//
//  HeaderRow.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct HeaderRow: View {
    let name: String
    let value: String
    let expanded: Bool
    let onCopy: (_ text: String, _ confirmation: String) -> Void

    @State private var revealed = false

    private static let mask = "••••••••••••"

    private var isSensitive: Bool { SensitiveHeaders.contains(name) }
    private var isHidden: Bool { isSensitive && !revealed }

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing12) {
            Text(name)
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.headerNameColumn, alignment: .leading)
                .lineLimit(1)
            Text(isHidden ? Self.mask : value)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(expanded ? nil : 1)
            if isSensitive { revealButton }
        }
        .font(Theme.mono(12, .regular))
        .padding(.horizontal, Theme.Spacing.spacing14)
        .padding(.vertical, Theme.Spacing.spacing10)
        .contentShape(Rectangle())
        .contextMenu { menu }
    }

    private var revealButton: some View {
        Button { revealed.toggle() } label: {
            Image(systemName: isHidden ? "eye" : "eye.slash")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.chip, height: Theme.Size.chip)
        }
        .accessibilityLabel(isHidden ? "Show \(name)" : "Hide \(name)")
    }

    @ViewBuilder
    private var menu: some View {
        Button { onCopy(value, "Value copied") } label: {
            Label("Copy value", systemImage: "doc.on.doc")
        }
        Button { onCopy("\(name): \(value)", "Header copied") } label: {
            Label("Copy header", systemImage: "text.badge.plus")
        }
    }
}
