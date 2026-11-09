#if os(iOS)
import SwiftUI

/// Shown when there is nothing to list, either yet or after filtering.
struct EmptyTimeline: View {
    let isFiltered: Bool

    private static let topOffset: CGFloat = 80

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: isFiltered ? "line.3.horizontal.decrease" : "arrow.up.arrow.down")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.tertiary)
                .padding(.bottom, Theme.Spacing.xs)
            Text(isFiltered ? "No matching requests" : "No requests yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text)
            Text(isFiltered ? "Try removing a filter or changing the search." : "Requests your app makes will show up here.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Self.topOffset)
    }
}
#endif
