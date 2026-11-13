//
//  InspectorView.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

struct InspectorView: View {
    @StateObject private var model: InspectorModel
    let onClose: () -> Void

    init(store: NetworkStore = Snitch.store, onClose: @escaping () -> Void) {
        _model = StateObject(wrappedValue: InspectorModel(store: store))
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            TimelineView(model: model, onClose: onClose)
        }
        .tint(Theme.text)
        .task { await model.observe() }
    }
}
