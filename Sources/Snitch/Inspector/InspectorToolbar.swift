//
//  InspectorToolbar.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct InspectorToolbar: ToolbarContent {
    let screen: InspectorScreen
    let screens: [InspectorScreen]
    let count: (InspectorScreen) -> Int
    @ObservedObject var model: InspectorModel
    @ObservedObject var events: EventLogModel
    let onClose: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }
        ToolbarItem(placement: .principal) {
            RecordingTitle(isPaused: model.isPaused, count: screens.count > 1 ? nil : count(screen))
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: model.togglePause) {
                Image(systemName: model.isPaused ? "play.fill" : "pause.fill")
            }
            .accessibilityLabel(model.isPaused ? "Resume recording" : "Pause recording")
            ClearButton(
                count: count(screen),
                isEnabled: canClear,
                noun: isNetwork ? "Request" : "Event",
                onClear: clear
            )
        }
    }

    private var isNetwork: Bool { screen == .network }

    private var canClear: Bool {
        isNetwork ? !model.entries.isEmpty || !model.pauses.isEmpty : count(screen) > 0
    }

    private func clear() {
        switch screen {
        case .network: model.clear()
        case .events(let source): events.clear(source: source)
        }
    }
}
