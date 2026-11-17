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
        static let emptyStateTop: CGFloat = 80
        static let floatingButtonInitialTop: CGFloat = 64
        static let switchSlide: CGFloat = 28
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

        static let badge: CGFloat = 16
        static let badgeOffset: CGFloat = 9
        static let errorBadge: CGFloat = 10
        static let toggleHeight: CGFloat = 26
        static let headerNameColumn: CGFloat = 112
        static let summaryMaxWidth: CGFloat = 240
        static let filterPanelWidth: CGFloat = 264
        static let statusTileHeight: CGFloat = 46
        static let filterDot: CGFloat = 6
        static let pauseIcon: CGFloat = 16
        static let pauseMinHeight: CGFloat = 32
        static let pendingDot: CGFloat = 4
        static let pendingDotLarge: CGFloat = 6
        static let eventDot: CGFloat = 10
        static let eventDotColumn: CGFloat = 22
        static let switcherSegment: CGFloat = 32
        static let switcherSegmentWidth: CGFloat = 76
        static let switcherIcon: CGFloat = 22
        static let sourceLogo: CGFloat = 30
        static let infoLabelColumn: CGFloat = 76
    }
}
