//
//  EntryFilter+Matching.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension EntryFilter {
    func matches(_ entry: NetworkEntry, search: String = "") -> Bool {
        matchesStatus(entry)
            && (methods.isEmpty || methods.contains(entry.method))
            && (hosts.isEmpty || hosts.contains(entry.displayHost))
            && matchesSearch(entry, search)
    }

    private func matchesStatus(_ entry: NetworkEntry) -> Bool {
        if statusClasses.isEmpty && codes.isEmpty && !failed && !pending { return true }
        let outcome = entry.outcome
        if failed && outcome == .failed { return true }
        if pending && outcome == .pending { return true }
        guard let code = entry.statusCode, outcome != .pending else { return false }
        return codes.contains(code) || statusClasses.contains { $0.contains(code) }
    }

    private func matchesSearch(_ entry: NetworkEntry, _ search: String) -> Bool {
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        return [entry.url?.absoluteString ?? "", entry.method, entry.displayStatus]
            .contains { $0.localizedCaseInsensitiveContains(query) }
    }
}
