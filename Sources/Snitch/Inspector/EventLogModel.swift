//
//  EventLogModel.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

@MainActor
final class EventLogModel: ObservableObject {
    @Published private(set) var sources: [String] = []
    @Published private(set) var icons: [String: UIImage] = [:]
    @Published private(set) var all: [AnalyticsEvent] = []
    @Published var showsAppEvents = true
    @Published var showsAutomatic = false
    @Published var search = ""

    let store: EventStore

    init(store: EventStore = Snitch.events) {
        self.store = store
        refresh()
    }

    var activeFilterCount: Int {
        (showsAppEvents ? 0 : 1) + (showsAutomatic ? 1 : 0)
    }

    func resetFilters() {
        showsAppEvents = true
        showsAutomatic = false
    }

    func observe() async {
        for await _ in store.changes() {
            refresh()
        }
    }

    func events(from source: String) -> [AnalyticsEvent] {
        all.filter { $0.source == source }
    }

    func automaticCount(from source: String) -> Int {
        events(from: source).filter(\.isAutomatic).count
    }

    func sections(
        from source: String,
        pauses: [NetworkStore.Pause] = [],
        calendar: Calendar = .current
    ) -> [EventSection] {
        let all = events(from: source)
        let shown = all.filter { ($0.isAutomatic ? showsAutomatic : showsAppEvents) && $0.matches(search) }
        let isNarrowed = activeFilterCount > 0 || !search.trimmingCharacters(in: .whitespaces).isEmpty
        let oldest = all.first?.date
        // A pause from before the oldest event belongs to events that were cleared.
        let shownPauses = isNarrowed ? [] : pauses.filter { pause in
            pause.end == nil || oldest.map { $0 <= pause.start } == true
        }
        let items = (shown.map(EventTimelineItem.event) + shownPauses.map(EventTimelineItem.pause))
            .sorted { $0.date > $1.date }

        var sections: [EventSection] = []
        for item in items {
            let day = calendar.startOfDay(for: item.date)
            if let last = sections.last, last.day == day {
                sections[sections.count - 1] = EventSection(day: day, items: last.items + [item])
            } else {
                sections.append(EventSection(day: day, items: [item]))
            }
        }
        return sections
    }

    func event(id: UUID) -> AnalyticsEvent? {
        all.last { $0.id == id }
    }

    /// The events a captured request uploaded, newest first.
    func events(in entry: NetworkEntry) -> [AnalyticsEvent] {
        guard !entry.requestBodyIDs.isEmpty else { return [] }
        return all.filter { entry.requestBodyIDs.contains($0.id) }.sorted { $0.date > $1.date }
    }

    func clear(source: String) {
        store.clear(source: source)
    }

    private func refresh() {
        sources = store.sources
        icons = Dictionary(uniqueKeysWithValues: sources.compactMap { source in
            store.icon(for: source).map { (source, $0) }
        })
        all = store.events
    }
}
