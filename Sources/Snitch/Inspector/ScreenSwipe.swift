//
//  ScreenSwipe.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import CoreGraphics

/// Decides which screen a sideways swipe on a timeline switches to.
enum ScreenSwipe {
    /// How far a drag must travel sideways to switch.
    static let distance: CGFloat = 60
    /// How fast, in points per second, a shorter flick must end to switch.
    static let flickSpeed: CGFloat = 500

    /// The screen next to `current` in the swipe's direction, or `nil` when the drag
    /// is mostly vertical, too short and slow, or runs past the first or last screen.
    /// Swiping left moves to the next screen, swiping right to the previous one.
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
