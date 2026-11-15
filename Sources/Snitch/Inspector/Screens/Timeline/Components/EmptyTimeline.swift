//
//  EmptyTimeline.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct EmptyTimeline: View {
    let isFiltered: Bool
    var noun = "requests"
    var emptyIcon = "arrow.up.arrow.down"
    var emptyMessage = "Requests your app makes will show up here."

    var body: some View {
        VStack(spacing: Theme.Spacing.spacing6) {
            Image(systemName: isFiltered ? "line.3.horizontal.decrease" : emptyIcon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.tertiary)
                .padding(.bottom, Theme.Spacing.spacing6)
            Text(isFiltered ? "No matching \(noun)" : "No \(noun) yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text)
            Text(isFiltered ? "Try removing a filter or changing the search." : emptyMessage)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.emptyStateTop)
    }
}
