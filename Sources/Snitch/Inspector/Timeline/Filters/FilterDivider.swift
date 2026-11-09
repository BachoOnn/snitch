#if os(iOS)
import SwiftUI

/// A hairline between filter panel sections.
struct FilterDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.veil(0.10))
            .frame(height: Theme.Size.hairline)
            .padding(.top, Theme.Spacing.s)
    }
}
#endif
