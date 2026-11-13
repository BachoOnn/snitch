//
//  NetworkStore+Changes.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension NetworkStore {
    /// A stream of snapshots: the current list right away, then the full list after every
    /// change, including a pause starting or ending.
    ///
    /// Slow consumers only see the newest snapshot. The stream ends when the consuming task is cancelled.
    public func changes() -> AsyncStream<[NetworkEntry]> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { self?.subscribers[id] = nil }
            }
            lock.withLock {
                subscribers[id] = continuation
                continuation.yield(items)
            }
        }
    }
}
