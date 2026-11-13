//
//  Theme+Layout.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import CoreGraphics

extension Theme {
    enum Spacing {
        static let spacing2: CGFloat = 2
        static let spacing4: CGFloat = 4
        static let spacing6: CGFloat = 6
        static let spacing8: CGFloat = 8
        static let spacing10: CGFloat = 10
        static let spacing12: CGFloat = 12
        static let spacing14: CGFloat = 14
        static let spacing16: CGFloat = 16
        static let spacing20: CGFloat = 20
        static let section: CGFloat = 18
        static let screen: CGFloat = 16
        static let floatingClearance: CGFloat = 100
        /// Top padding above an empty state's icon.
        static let emptyStateTop: CGFloat = 80
        /// How far below the top safe area the floating button first appears.
        static let floatingButtonInitialTop: CGFloat = 64
    }

    enum Radius {
        static let toggle: CGFloat = 7
        static let segment: CGFloat = 10
        static let tile: CGFloat = 12
        static let card: CGFloat = 16
        static let panel: CGFloat = 20
    }

    enum Size {
        static let touchTarget: CGFloat = 44
        static let floatingControl: CGFloat = 52
        static let field: CGFloat = 38
        static let row: CGFloat = 40
        static let chip: CGFloat = 28
        static let statusDot: CGFloat = 7
        static let hairline: CGFloat = 1
        static let methodPill = CGSize(width: 52, height: 28)

        /// A count badge, such as the active-filters count on ``GlassCircle``.
        static let badge: CGFloat = 16
        /// How far a badge overlaps the corner of what it's attached to.
        static let badgeOffset: CGFloat = 9
        /// The floating button's error badge.
        static let errorBadge: CGFloat = 10
        /// The Pretty/Raw segmented toggle.
        static let toggleHeight: CGFloat = 26
        /// The name column in a header row.
        static let headerNameColumn: CGFloat = 112
        /// The compact request/response summary line.
        static let summaryMaxWidth: CGFloat = 240
        /// The filter panel popover.
        static let filterPanelWidth: CGFloat = 264
        /// A status-class filter tile.
        static let statusTileHeight: CGFloat = 46
        /// The dot inside a status-class filter tile.
        static let filterDot: CGFloat = 6
        /// The pause marker's icon and minimum row height.
        static let pauseIcon: CGFloat = 16
        static let pauseMinHeight: CGFloat = 32
    }
}
