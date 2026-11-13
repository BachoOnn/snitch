//
//  RestTimer.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

@MainActor
final class RestTimer {
    private let delay: TimeInterval
    private let onRest: () -> Void
    private var task: Task<Void, Never>?

    init(delay: TimeInterval, onRest: @escaping () -> Void) {
        self.delay = delay
        self.onRest = onRest
    }

    func poke() {
        task?.cancel()
        task = Task { [weak self, delay] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.onRest()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
