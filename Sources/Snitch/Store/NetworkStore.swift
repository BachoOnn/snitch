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

    /// The maximum number of pauses kept.
    static let maxPauses = 50

    private let lock = NSLock()
    private var items: [NetworkEntry] = []
    private var pauseItems: [Pause] = []
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

    /// Pauses in the order they started, oldest first.
    public var pauses: [Pause] {
        lock.withLock { pauseItems }
    }

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

    /// Removes all entries and finished pauses. A pause still in progress is kept.
    public func clear() {
        mutate {
            let pauses = pauseItems.filter { $0.end == nil }
            guard !items.isEmpty || pauses.count != pauseItems.count else { return false }
            items.removeAll()
            pauseItems = pauses
            return true
        }
    }

    /// Appends a new entry, dropping the oldest ones if the store is full.
    func insert(_ entry: NetworkEntry) {
        mutate {
            items.append(entry)
            if items.count > maxCount {
                items.removeFirst(items.count - maxCount)
            }
            return true
        }
    }

    /// Replaces the stored entry with the same id. Does nothing if it was already dropped.
    func update(_ entry: NetworkEntry) {
        mutate {
            guard let index = items.lastIndex(where: { $0.id == entry.id }) else { return false }
            items[index] = entry
            return true
        }
    }

    /// Starts a pause unless one is already in progress.
    func beginPause(at date: Date = Date()) {
        mutate {
            guard pauseItems.last?.end != nil || pauseItems.isEmpty else { return false }
            pauseItems.append(Pause(id: UUID(), start: date, end: nil))
            if pauseItems.count > Self.maxPauses {
                pauseItems.removeFirst(pauseItems.count - Self.maxPauses)
            }
            return true
        }
    }

    /// Ends the pause in progress, if any.
    func endPause(at date: Date = Date()) {
        mutate {
            guard let last = pauseItems.indices.last, pauseItems[last].end == nil else { return false }
            pauseItems[last].end = date
            return true
        }
    }

    /// Applies `change` under the lock and notifies subscribers if it returns `true`.
    private func mutate(_ change: () -> Bool) {
        lock.withLock {
            guard change() else { return }
            // Yield under the lock so subscribers never see snapshots out of order.
            for continuation in subscribers.values {
                continuation.yield(items)
            }
        }
    }
}
