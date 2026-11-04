import Foundation

/// A thread-safe, in-memory list of captured entries.
///
/// Entries are kept in the order their requests started, oldest first.
/// When the store is full, the oldest entries are dropped.
public final class NetworkStore: @unchecked Sendable {
    /// The maximum number of entries kept.
    public let maxCount: Int

    private let lock = NSLock()
    private var items: [NetworkEntry] = []
    private var subscribers: [UUID: AsyncStream<[NetworkEntry]>.Continuation] = [:]

    /// Creates an empty store that keeps at most `maxCount` entries.
    public init(maxCount: Int = 500) {
        precondition(maxCount > 0, "maxCount must be positive")
        self.maxCount = maxCount
    }

    /// A snapshot of all entries, oldest first.
    public var entries: [NetworkEntry] {
        lock.withLock { items }
    }

    /// A stream of snapshots: the current list right away, then the full list after every change.
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

    /// Removes all entries.
    public func clear() {
        mutate { items in
            guard !items.isEmpty else { return false }
            items.removeAll()
            return true
        }
    }

    /// Appends a new entry, dropping the oldest ones if the store is full.
    func insert(_ entry: NetworkEntry) {
        mutate { items in
            items.append(entry)
            if items.count > maxCount {
                items.removeFirst(items.count - maxCount)
            }
            return true
        }
    }

    /// Replaces the stored entry with the same id. Does nothing if it was already dropped.
    func update(_ entry: NetworkEntry) {
        mutate { items in
            guard let index = items.lastIndex(where: { $0.id == entry.id }) else { return false }
            items[index] = entry
            return true
        }
    }

    /// Applies `change` and notifies subscribers if it returns `true`.
    private func mutate(_ change: (inout [NetworkEntry]) -> Bool) {
        lock.withLock {
            guard change(&items) else { return }
            // Yield under the lock so subscribers never see snapshots out of order.
            for continuation in subscribers.values {
                continuation.yield(items)
            }
        }
    }
}
