//
//  DetailCopyButton.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct DetailCopyButton: View {
    var accessibilityLabel = "Copy request and response"
    let onCopy: () -> Void
    var onCopyAsCurl: (() -> Void)?

    @State private var center: CGPoint? = Self.lastCenter
    @State private var isDragging = false

    private static var lastCenter: CGPoint?

    var body: some View {
        Button {
            guard !isDragging else { return }
            onCopy()
        } label: {
            GlassCircle(systemImage: "doc.on.doc")
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(onCopyAsCurl == nil ? "Drag to move." : "Long press for more options. Drag to move.")
        .contextMenu { menu }
        .floatingDrag(
            center: $center,
            isDragging: $isDragging,
            size: CGSize(width: Theme.Size.floatingControl, height: Theme.Size.floatingControl)
        )
        .ignoresSafeArea(.keyboard)
        .onChange(of: center) { Self.lastCenter = $0 }
    }

    @ViewBuilder
    private var menu: some View {
        Button(action: onCopy) {
            Label("Copy all", systemImage: "doc.on.doc")
        }
        if let onCopyAsCurl {
            Button(action: onCopyAsCurl) {
                Label("Copy as cURL", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        }
    }
}
