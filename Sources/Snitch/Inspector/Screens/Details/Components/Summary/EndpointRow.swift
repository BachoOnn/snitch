//
//  EndpointRow.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI
import UIKit

struct EndpointRow: View {
    let entry: NetworkEntry
    let onCopy: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.spacing8) {
            SelectableText(text: endpoint)
                .id(colorScheme)
                .accessibilityLabel(entry.url?.absoluteString ?? "")
            CopyChip(accessibilityLabel: "Copy URL", action: onCopy)
                .padding(.top, -5)
        }
    }

    private var endpoint: NSAttributedString {
        let font = UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        let text = NSMutableAttributedString(
            string: entry.displayHost,
            attributes: [.font: font, .foregroundColor: UIColor(Theme.tertiary)]
        )
        text.append(NSAttributedString(
            string: entry.displayPath,
            attributes: [.font: font, .foregroundColor: UIColor(Theme.text)]
        ))
        return text
    }
}
