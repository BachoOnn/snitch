//
//  NetworkStore+Entries.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension NetworkStore {
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

    func insert(_ entry: NetworkEntry) {
        mutate {
            items.append(entry)
            if items.count > maxCount {
                items.removeFirst(items.count - maxCount)
            }
            return true
        }
    }

    func update(_ entry: NetworkEntry) {
        mutate {
            guard let index = items.lastIndex(where: { $0.id == entry.id }) else { return false }
            items[index] = entry
            return true
        }
    }
}
