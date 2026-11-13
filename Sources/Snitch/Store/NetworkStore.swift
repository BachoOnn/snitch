//
//  NetworkStore.swift
//  Snitch
//
//  Created by BOniani on 04/11/2026.
//

import Foundation

/// A thread-safe, in-memory list of captured entries.
///
/// Entries are kept in the order their requests started, oldest first.
/// When the store is full, the oldest entries are dropped.
public final class NetworkStore: @unchecked Sendable {
    /// A span of time when capture was paused and requests were not recorded.
    public struct Pause: Identifiable, Equatable, Sendable {
        /// A unique identifier for this pause.
        public let id: UUID
        /// When capture was paused.
        public let start: Date
        /// When capture resumed, or `nil` while it is still paused.
        public internal(set) var end: Date?
    }

    /// The maximum number of entries kept.
    public let maxCount: Int

    static let maxPauses = 50

    let lock = NSLock()
    var items: [NetworkEntry] = []
    var pauseItems: [Pause] = []
    var subscribers: [UUID: AsyncStream<[NetworkEntry]>.Continuation] = [:]

    /// Creates an empty store that keeps at most `maxCount` entries.
    public init(maxCount: Int = 500) {
        precondition(maxCount > 0, "maxCount must be positive")
        self.maxCount = maxCount
    }

    /// A snapshot of all entries, oldest first.
    public var entries: [NetworkEntry] {
        lock.withLock { items }
    }

    /// Pauses in the order they started, oldest first.
    public var pauses: [Pause] {
        lock.withLock { pauseItems }
    }

    /// Applies `change` under the lock and notifies subscribers if it returns `true`.
    func mutate(_ change: () -> Bool) {
        lock.withLock {
            guard change() else { return }
            for continuation in subscribers.values {
                // Yield under the lock so subscribers never see snapshots out of order.
                continuation.yield(items)
            }
        }
    }
}
