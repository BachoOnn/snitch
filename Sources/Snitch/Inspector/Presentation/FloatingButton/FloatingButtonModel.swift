//
//  FloatingButtonModel.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

@MainActor
final class FloatingButtonModel: ObservableObject {
    static let restDelay: TimeInterval = 5
    @Published private(set) var activity = 0
    @Published private(set) var hasNewErrors = false
    @Published private(set) var isResting = false

    private var lastSeen = Date()
    private var lastID: UUID?
    private var restTimer: RestTimer?

    init(restDelay: TimeInterval = FloatingButtonModel.restDelay) {
        restTimer = RestTimer(delay: restDelay) { [weak self] in self?.isResting = true }
        Task { [weak self] in
            for await entries in Snitch.store.changes() {
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
        lastSeen = Date()
        hasNewErrors = false
    }

    private func update(_ entries: [NetworkEntry]) {
        if let last = entries.last?.id, last != lastID {
            lastID = last
            activity += 1
        }
        hasNewErrors = entries.contains { $0.startDate > lastSeen && $0.outcome.isError }
    }
}
