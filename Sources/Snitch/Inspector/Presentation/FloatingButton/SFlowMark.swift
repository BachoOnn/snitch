//
//  SFlowMark.swift
//  Snitch
//
//  Created by BOniani on 11/11/2026.
//

import SwiftUI

struct SFlowMark: Shape {
    private static let grid: CGFloat = 42

    static func lineWidth(for size: CGFloat) -> CGFloat {
        size * 3.2 / grid
    }

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / Self.grid
        let origin = CGPoint(
            x: rect.midX - Self.grid * scale / 2,
            y: rect.midY - Self.grid * scale / 2
        )
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: origin.x + x * scale, y: origin.y + y * scale)
        }

        var path = Path()
        path.move(to: p(27.5, 12))
        path.addCurve(to: p(14.5, 16.8), control1: p(22, 11.2), control2: p(14.5, 11.5))
        path.addCurve(to: p(27.5, 25.2), control1: p(14.5, 22.6), control2: p(27.5, 19.4))
        path.addCurve(to: p(14.5, 30), control1: p(27.5, 30.5), control2: p(20, 30.8))
        path.move(to: p(23.8, 8.4))
        path.addLine(to: p(27.6, 12))
        path.addLine(to: p(23.8, 15.6))
        path.move(to: p(18.2, 26.4))
        path.addLine(to: p(14.4, 30))
        path.addLine(to: p(18.2, 33.6))
        return path
    }
}
