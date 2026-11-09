import SwiftUI

/// Where the summary card's bottom edge is, relative to the top of the scroll view.
struct SummaryBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

extension View {
    /// Reports this view's bottom edge in the named coordinate space through `SummaryBottomKey`.
    func reportsSummaryBottom(in space: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SummaryBottomKey.self, value: proxy.frame(in: .named(space)).maxY)
            }
        )
    }
}
