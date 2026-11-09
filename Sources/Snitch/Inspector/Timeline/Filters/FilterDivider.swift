import SwiftUI

/// A hairline between filter panel sections.
struct FilterDivider: View {
    var body: some View {
        Hairline(color: Theme.veil(0.10))
            .padding(.top, Theme.Spacing.s)
    }
}
