import SwiftUI

/// The inspector's design system: colors here, layout in `Theme+Layout`, type in
/// `Theme+Typography`.
///
/// Colors live in `Resources/Media.xcassets/Colors`, each with a light and a dark
/// value, so they follow the system appearance on their own.
enum Theme {
    // MARK: Surfaces

    static let background = asset("Background")
    static let surface = asset("Surface")
    static let border = asset("Border")
    static let divider = asset("Divider")
    /// Fills for selected segments and small separators.
    static let control = asset("Control")
    static let codeBackground = asset("CodeBackground")

    // MARK: Text

    static let text = asset("Text")
    /// Supporting text that still needs to read clearly, such as stats and inactive tabs.
    static let textMuted = asset("TextMuted")
    static let secondary = asset("Secondary")
    static let tertiary = asset("Tertiary")
    /// The quietest text, such as line numbers and fast durations.
    static let faint = asset("Faint")

    // MARK: Brand and status

    /// The brand color as text and strokes. Darker in light mode so it stays readable on white.
    static let accent = asset("Accent")
    /// The brand color as a solid fill. The same in both modes; pair it with ``onAccent``.
    static let accentFill = asset("AccentFill")
    static let onAccent = asset("OnAccent")
    static let warning = asset("Warning")
    static let danger = asset("Danger")
    static let info = asset("Info")
    /// Pauses and other neutral markers.
    static let silver = asset("Silver")
    /// The floating button's error badge.
    static let badge = asset("Badge")

    // MARK: Code

    static let jsonKey = asset("JSONKey")
    static let jsonString = asset("JSONString")
    static let jsonNumber = asset("JSONNumber")

    /// A translucent wash for chips and hairlines: white over dark, black over light.
    static func veil(_ opacity: Double) -> Color {
        asset("Veil").opacity(opacity)
    }

    /// The color that signals how a request ended.
    static func color(for outcome: NetworkEntry.Outcome) -> Color {
        switch outcome {
        case .pending, .success: return accent
        case .clientError: return warning
        case .serverError, .failed: return danger
        }
    }

    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
