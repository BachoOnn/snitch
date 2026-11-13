//
//  FloatingDot.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct FloatingDot: View {
    @ObservedObject var model: FloatingButtonModel
    @State private var pulse = false

    static let frameSize: CGFloat = 40
    private static let diameter = frameSize
    private static let restingOpacity: Double = 0.5

    var body: some View {
        Image("SFlowMark", bundle: .module)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(Theme.onAccent)
            .frame(width: Self.diameter, height: Self.diameter)
            .background(Theme.accentFill, in: Circle())
            .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
            .scaleEffect(pulse ? 1.12 : 1)
            .compositingGroup()
            .opacity(model.isResting ? Self.restingOpacity : 1)
            .animation(.easeInOut(duration: model.isResting ? 0.6 : 0.15), value: model.isResting)
            .overlay(alignment: .topTrailing) {
                if model.hasNewErrors { badge }
            }
            .frame(width: Self.frameSize, height: Self.frameSize)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(model.hasNewErrors ? "Open network inspector, new errors" : "Open network inspector")
            .accessibilityAction { InspectorPresenter.present() }
            .onChange(of: model.activity) { _ in pulseOnce() }
    }

    private var badge: some View {
        Circle()
            .fill(Theme.badge)
            .frame(width: Theme.Size.errorBadge, height: Theme.Size.errorBadge)
            .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))
            .offset(x: 1, y: -1)
    }

    private func pulseOnce() {
        withAnimation(.easeOut(duration: 0.12)) { pulse = true }
        withAnimation(.easeIn(duration: 0.25).delay(0.12)) { pulse = false }
    }
}
