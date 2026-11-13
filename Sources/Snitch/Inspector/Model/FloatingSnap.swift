//
//  FloatingSnap.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import CoreGraphics

enum FloatingSnap {
    static func clamp(_ center: CGPoint, size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        let minX = bounds.minX + margin + size.width / 2
        let maxX = max(minX, bounds.maxX - margin - size.width / 2)
        let minY = bounds.minY + margin + size.height / 2
        let maxY = max(minY, bounds.maxY - margin - size.height / 2)
        return CGPoint(x: min(max(center.x, minX), maxX), y: min(max(center.y, minY), maxY))
    }

    static func bottomTrailing(size: CGSize, in bounds: CGRect, margin: CGFloat) -> CGPoint {
        CGPoint(x: bounds.maxX - margin - size.width / 2, y: bounds.maxY - margin - size.height / 2)
    }
}
