//
//  Theme.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

enum Theme {

    static let background = asset("Background")
    static let surface = asset("Surface")
    static let border = asset("Border")
    static let divider = asset("Divider")
    static let control = asset("Control")
    static let codeBackground = asset("CodeBackground")

    static let text = asset("Text")
    static let textMuted = asset("TextMuted")
    static let secondary = asset("Secondary")
    static let tertiary = asset("Tertiary")
    static let faint = asset("Faint")

    static let accent = asset("Accent")
    static let accentFill = asset("AccentFill")
    static let onAccent = asset("OnAccent")
    static let warning = asset("Warning")
    static let danger = asset("Danger")
    static let info = asset("Info")
    static let silver = asset("Silver")
    static let badge = asset("Badge")

    static let jsonKey = asset("JSONKey")
    static let jsonString = asset("JSONString")
    static let jsonNumber = asset("JSONNumber")

    static func veil(_ opacity: Double) -> Color {
        asset("Veil").opacity(opacity)
    }

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
