//
//  BodySection+Search.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import SwiftUI

/// Loading the body document and finding text inside it.
extension BodySection {
    func load() async {
        guard let data, !data.isEmpty else { return }
        let key = key
        let result = await BodyDocumentLoader.load(data, pretty: pretty, key: key)
        guard !Task.isCancelled else { return }
        loaded = (key, result)
        find(query)
    }

    func find(_ text: String) {
        search?.cancel()
        guard case .text(let document)? = result,
              !text.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            matches = []
            return
        }
        search = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            let found = await Task.detached(priority: .userInitiated) { document.rows(matching: text) }.value
            guard !Task.isCancelled, text == query else { return }
            matches = found
        }
    }
}
