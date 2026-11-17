//
//  ScreenSwipe.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import CoreGraphics

enum ScreenSwipe {
    static let distance: CGFloat = 60
    static let flickSpeed: CGFloat = 500

    static func target(
        from current: InspectorScreen,
        in screens: [InspectorScreen],
        translation: CGPoint,
        velocity: CGPoint
    ) -> InspectorScreen? {
        let isFlick = abs(velocity.x) >= flickSpeed && (velocity.x < 0) == (translation.x < 0)
        guard abs(translation.x) > 2 * abs(translation.y),
              abs(translation.x) >= distance || isFlick,
              let index = screens.firstIndex(of: current) else { return nil }
        let next = index + (translation.x < 0 ? 1 : -1)
        return screens.indices.contains(next) ? screens[next] : nil
    }
}
