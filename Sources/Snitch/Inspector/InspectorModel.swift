#if os(iOS)
import SwiftUI

/// State shared by the inspector's screens. Mirrors the store and holds the filters.
@MainActor
final class InspectorModel: ObservableObject {
    @Published private(set) var entries: [NetworkEntry] = []
    @Published private(set) var pauses: [NetworkStore.Pause] = []
    @Published private(set) var isPaused = Snitch.isPaused
    @Published var filter = EntryFilter()
    @Published var search = ""

    let store: NetworkStore

    init(store: NetworkStore = Snitch.store) {
        self.store = store
        entries = store.entries
        pauses = store.pauses
    }

    /// Follows the store until the calling task is cancelled.
    func observe() async {
        for await snapshot in store.changes() {
            entries = snapshot
            pauses = store.pauses
            isPaused = Snitch.isPaused
        }
    }

    var sections: [TimelineSection] {
        Timeline.sections(entries: entries, pauses: pauses, filter: filter, search: search)
    }

    func entry(id: UUID) -> NetworkEntry? {
        entries.last { $0.id == id }
    }

    /// Methods seen so far, for the filter menu.
    var methods: [String] { Array(Set(entries.map(\.method))).sorted() }

    /// Hosts seen so far, for the filter menu.
    var hosts: [String] { Array(Set(entries.map(\.displayHost))).filter { !$0.isEmpty }.sorted() }

    func togglePause() {
        isPaused ? Snitch.resume() : Snitch.pause()
        isPaused = Snitch.isPaused
    }

    func clear() {
        store.clear()
    }
}
#endif
