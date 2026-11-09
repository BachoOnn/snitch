import SwiftUI

/// The Pretty · Raw switch for JSON bodies.
struct BodyFormatToggle: View {
    @Binding var pretty: Bool

    private static let height: CGFloat = 26

    var body: some View {
        HStack(spacing: 0) {
            option("Pretty", isPretty: true)
            option("Raw", isPretty: false)
        }
        .padding(Theme.Spacing.xxxs)
        .cardStyle(radius: Theme.Radius.segment)
    }

    private func option(_ title: String, isPretty: Bool) -> some View {
        let isSelected = pretty == isPretty
        return Button(title) { pretty = isPretty }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? Theme.text : Theme.secondary)
            .padding(.horizontal, Theme.Spacing.m)
            .frame(height: Self.height)
            .background(isSelected ? Theme.control : .clear, in: RoundedRectangle(cornerRadius: Theme.Radius.toggle))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
