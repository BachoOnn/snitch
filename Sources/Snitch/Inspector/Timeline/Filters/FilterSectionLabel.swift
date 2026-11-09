import SwiftUI

/// A small uppercase heading inside the filter panel.
struct FilterSectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Theme.sectionLabel)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.s)
            .padding(.bottom, Theme.Spacing.xs)
    }
}
