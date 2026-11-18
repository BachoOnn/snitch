//
//  FloatingButtonModel.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

@MainActor
final class FloatingButtonModel: ObservableObject {
    nonisolated static let restDelay: TimeInterval = 5
    @Published private(set) var activity = 0
    @Published private(set) var hasNewErrors = false
    @Published private(set) var isResting = false

    private var entries: [NetworkEntry] = []
    private var seenErrors: Set<UUID> = []
    private var lastID: UUID?
    private var restTimer: RestTimer?

    init(store: NetworkStore = Snitch.store, restDelay: TimeInterval = FloatingButtonModel.restDelay) {
        restTimer = RestTimer(delay: restDelay) { [weak self] in self?.isResting = true }
        Task { [weak self] in
            for await entries in store.changes() {
                guard let self else { return }
                self.update(entries)
            }
        }
    }

    func wake() {
        isResting = false
        restTimer?.poke()
    }

    func markSeen() {
        seenErrors = Set(entries.filter(\.outcome.isError).map(\.id))
        hasNewErrors = false
    }

    private func update(_ entries: [NetworkEntry]) {
        self.entries = entries
        if let last = entries.last?.id, last != lastID {
            lastID = last
            activity += 1
        }
        hasNewErrors = entries.contains { $0.outcome.isError && !seenErrors.contains($0.id) }
    }
}
