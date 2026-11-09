#if os(iOS)
import SwiftUI

/// Colors and type used across the inspector. The inspector is always dark.
enum Theme {
    static let background = Color(hex: 0x0B0F0D)
    static let surface = Color(hex: 0x121815)
    static let border = Color(hex: 0x1F2A24)
    static let text = Color(hex: 0xE8F0EB)
    static let secondary = Color(hex: 0x8FA398)
    static let tertiary = Color(hex: 0x6F8378)

    /// The one brand color. Used for live, successful and selected states.
    static let accent = Color(hex: 0x7CF0A9)
    static let warning = Color(hex: 0xF5B860)
    static let danger = Color(hex: 0xFF7A70)
    static let info = Color(hex: 0x9CC8FF)
    /// Pauses and other neutral markers.
    static let silver = Color(hex: 0xAEB9B3)

    static let jsonKey = Color(hex: 0x9FD8B5)
    static let jsonString = Color(hex: 0xF2D49B)
    static let jsonNumber = Color(hex: 0x9CC8FF)

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// The wide, heavy face used for the SNITCH title.
    static let title = Font.system(size: 19, weight: .heavy).width(.expanded)

    /// Small uppercase section labels, such as `HEADERS · 6`.
    static let sectionLabel = Font.system(size: 11, weight: .semibold)

    static func color(for outcome: NetworkEntry.Outcome) -> Color {
        switch outcome {
        case .pending, .success: return accent
        case .clientError: return warning
        case .serverError, .failed: return danger
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

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
