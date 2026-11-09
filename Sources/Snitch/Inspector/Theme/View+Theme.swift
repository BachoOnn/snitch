#if os(iOS)
import SwiftUI

extension View {
    /// Gives the navigation bar the inspector's background, so scrolled content
    /// never shows through behind the title. Toolbar buttons keep their glass.
    func inspectorBarBackground() -> some View {
        toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    /// Applies the small uppercase section-label style.
    func sectionLabelStyle() -> some View {
        font(Theme.sectionLabel)
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
    }
}
#endif
