#if os(iOS)
import SwiftUI

/// The inspector's root: a navigation stack that starts on the timeline.
struct InspectorView: View {
    @StateObject private var model: InspectorModel
    let onClose: () -> Void

    init(store: NetworkStore = Tapwire.store, onClose: @escaping () -> Void) {
        _model = StateObject(wrappedValue: InspectorModel(store: store))
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            TimelineView(model: model, onClose: onClose)
        }
        .tint(Theme.text)
        .preferredColorScheme(.dark)
        .task { await model.observe() }
    }
}
#endif
