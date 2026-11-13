//
//  Wire.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct Wire: View {
    var dashed = false

    static let width: CGFloat = 2

    var body: some View {
        if dashed {
            VerticalLine()
                .stroke(Theme.silver.opacity(0.45), style: StrokeStyle(lineWidth: Self.width, dash: [3, 4]))
                .frame(width: Self.width)
        } else {
            Rectangle()
                .fill(Theme.border)
                .frame(width: Self.width)
        }
    }

    private struct VerticalLine: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            }
        }
    }
}

extension View {
    func onWire(dashed: Bool = false) -> some View {
        frame(width: Theme.Size.methodPill.width)
            .frame(maxHeight: .infinity)
            .background(Wire(dashed: dashed))
    }
}
