//
//  NetworkStore+Pauses.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension NetworkStore {
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

    func endPause(at date: Date = Date()) {
        mutate {
            guard let last = pauseItems.indices.last, pauseItems[last].end == nil else { return false }
            pauseItems[last].end = date
            return true
        }
    }
}
