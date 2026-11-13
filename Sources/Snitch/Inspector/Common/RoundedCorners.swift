//
//  RoundedCorners.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI
import UIKit

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}
