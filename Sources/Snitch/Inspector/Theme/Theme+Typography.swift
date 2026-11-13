//
//  Theme+Typography.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

extension Theme {
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static let title = Font.system(size: 19, weight: .heavy).width(.expanded)

    static let sectionLabel = Font.system(size: 11, weight: .semibold)
}
