//
//  EventStore.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import UIKit

final class EventStore: @unchecked Sendable {
    let maxCount: Int

    private let lock = NSLock()
    private var items: [AnalyticsEvent] = []
    private var sourceNames: [String] = []
    private var sourceIcons: [String: UIImage] = [:]
    private var subscribers: [UUID: AsyncStream<Void>.Continuation] = [:]

    init(maxCount: Int = 500) {
        precondition(maxCount > 0, "maxCount must be positive")
        self.maxCount = maxCount
    }

    var events: [AnalyticsEvent] {
        lock.withLock { items }
    }

    var sources: [String] {
        lock.withLock { sourceNames }
    }

    func icon(for source: String) -> UIImage? {
        lock.withLock { sourceIcons[source] }
    }

    func register(source: String, icon: UIImage? = nil) {
        mutate {
            let isNew = !sourceNames.contains(source)
            if isNew { sourceNames.append(source) }
            if let icon { sourceIcons[source] = icon }
            return isNew || icon != nil
        }
    }

    func insert(_ event: AnalyticsEvent) {
        mutate {
            if !sourceNames.contains(event.source) { sourceNames.append(event.source) }
            items.append(event)
            if items.count > maxCount {
                items.removeFirst(items.count - maxCount)
            }
            return true
        }
    }

    func clear(source: String) {
        mutate {
            let before = items.count
            items.removeAll { $0.source == source }
            return items.count != before
        }
    }

    func changes() -> AsyncStream<Void> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { self?.subscribers[id] = nil }
            }
            lock.withLock {
                subscribers[id] = continuation
                continuation.yield()
            }
        }
    }

    private func mutate(_ change: () -> Bool) {
        lock.withLock {
            guard change() else { return }
            for continuation in subscribers.values { continuation.yield() }
        }
    }
}
