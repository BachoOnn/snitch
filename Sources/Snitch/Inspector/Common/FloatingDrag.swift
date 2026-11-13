//
//  FloatingDrag.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

private struct FloatingDrag: ViewModifier {
    @Binding var center: CGPoint?
    @Binding var isDragging: Bool
    let size: CGSize
    let margin: CGFloat

    @GestureState private var translation: CGSize = .zero

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let bounds = CGRect(origin: .zero, size: proxy.size)
            let resting = center.map { FloatingSnap.clamp($0, size: size, in: bounds, margin: margin) }
                ?? FloatingSnap.bottomTrailing(size: size, in: bounds, margin: margin)

            content
                .position(
                    x: resting.x + translation.width,
                    y: resting.y + translation.height
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 8, coordinateSpace: .global)
                        .updating($translation) { value, state, _ in state = value.translation }
                        .onChanged { _ in isDragging = true }
                        .onEnded { value in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { isDragging = false }
                            let dropped = CGPoint(x: resting.x + value.translation.width, y: resting.y + value.translation.height)
                            center = FloatingSnap.clamp(dropped, size: size, in: bounds, margin: margin)
                        }
                )
        }
    }
}

extension View {
    func floatingDrag(
        center: Binding<CGPoint?>,
        isDragging: Binding<Bool>,
        size: CGSize,
        margin: CGFloat = 16
    ) -> some View {
        modifier(
            FloatingDrag(
                center: center,
                isDragging: isDragging,
                size: size,
                margin: margin
            )
        )
    }
}
