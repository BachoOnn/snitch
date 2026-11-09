import SwiftUI

extension View {
    /// Gives the navigation bar the inspector's background, so scrolled content
    /// never shows through behind the title. Toolbar buttons keep their glass.
    func inspectorBarBackground() -> some View {
        toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    /// A filled, outlined rounded rectangle behind the view, the shape of every card.
    func cardStyle(
        radius: CGFloat = Theme.Radius.card,
        fill: Color = Theme.surface,
        stroke: Color = Theme.border
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        return background(fill, in: shape).overlay(shape.strokeBorder(stroke))
    }

    /// Applies the small uppercase section-label style.
    func sectionLabelStyle() -> some View {
        font(Theme.sectionLabel)
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
    }
}
