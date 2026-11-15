//
//  ClearButton.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct ClearButton: View {
    let count: Int
    let isEnabled: Bool
    var noun = "Request"
    let onClear: () -> Void

    @State private var confirming = false

    var body: some View {
        Button { confirming = true } label: {
            Image(systemName: "trash")
        }
        .accessibilityLabel("Clear all \(noun.lowercased())s")
        .disabled(!isEnabled)
        .confirmationDialog(title, isPresented: $confirming, titleVisibility: .visible) {
            Button(confirmTitle, role: .destructive, action: onClear)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("They're removed from Snitch only. Your app isn't affected.")
        }
    }

    private var title: String {
        count == 1 ? "Clear 1 \(noun.lowercased())?" : "Clear all \(count) \(noun.lowercased())s?"
    }

    private var confirmTitle: String {
        count == 1 ? "Clear \(noun)" : "Clear \(count) \(noun)s"
    }
}
