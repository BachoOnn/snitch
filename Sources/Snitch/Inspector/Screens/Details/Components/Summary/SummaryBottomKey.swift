//
//  SummaryBottomKey.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct SummaryBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

extension View {
    func reportsSummaryBottom(in space: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SummaryBottomKey.self, value: proxy.frame(in: .named(space)).maxY)
            }
        )
    }
}
