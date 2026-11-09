#if os(iOS)
import SwiftUI
import UIKit

/// Colors and type used across the inspector. Every color has a dark and a light
/// value and follows the system appearance.
enum Theme {
    static let background = adaptive(dark: 0x0B0F0D, light: 0xF5F7F6)
    static let surface = adaptive(dark: 0x121815, light: 0xFFFFFF)
    static let border = adaptive(dark: 0x1F2A24, light: 0xDCE4DF)
    static let divider = adaptive(dark: 0x1A221E, light: 0xE6ECE8)
    /// Fills for selected segments and small separators.
    static let control = adaptive(dark: 0x24302A, light: 0xE4EBE7)
    static let codeBackground = adaptive(dark: 0x0F1411, light: 0xF0F4F1)

    static let text = adaptive(dark: 0xE8F0EB, light: 0x0E1512)
    /// Supporting text that still needs to read clearly, such as stats and inactive tabs.
    static let textMuted = adaptive(dark: 0xC9D6CE, light: 0x34423A)
    static let secondary = adaptive(dark: 0x8FA398, light: 0x56675D)
    static let tertiary = adaptive(dark: 0x6F8378, light: 0x6C7D73)
    /// The quietest text, such as line numbers and fast durations.
    static let faint = adaptive(dark: 0x5C6E64, light: 0x8E9B93)

    /// The brand color as text and strokes. Darker in light mode so it stays readable on white.
    static let accent = adaptive(dark: 0x7CF0A9, light: 0x14864A)
    /// The brand color as a solid fill. The same in both modes; pair it with ``onAccent``.
    static let accentFill = Color(hex: 0x7CF0A9)
    static let onAccent = Color(hex: 0x06210F)

    static let warning = adaptive(dark: 0xF5B860, light: 0xAD6500)
    static let danger = adaptive(dark: 0xFF7A70, light: 0xCC3A2F)
    static let info = adaptive(dark: 0x9CC8FF, light: 0x2D6BC9)
    /// Pauses and other neutral markers.
    static let silver = adaptive(dark: 0xAEB9B3, light: 0x76837C)
    /// The floating button's error badge.
    static let badge = Color(hex: 0xFF5A4E)

    static let jsonKey = adaptive(dark: 0x9FD8B5, light: 0x18764A)
    static let jsonString = adaptive(dark: 0xF2D49B, light: 0x955A00)
    static let jsonNumber = adaptive(dark: 0x9CC8FF, light: 0x2B5FBF)

    /// A translucent wash for chips and hairlines: white over dark, black over light.
    static func veil(_ opacity: Double) -> Color {
        Color(UIColor { traits in
            UIColor(white: traits.userInterfaceStyle == .dark ? 1 : 0, alpha: opacity)
        })
    }

    private static func adaptive(dark: UInt32, light: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }

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
