//
//  BodyDocumentLoader.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

enum BodyDocumentLoader {
    enum Result: Sendable {
        case text(BodyDocument)
        case binary
    }

    private final class Entry {
        let result: Result
        init(_ result: Result) { self.result = result }
    }

    private static let cache: NSCache<NSString, Entry> = {
        let cache = NSCache<NSString, Entry>()
        cache.countLimit = 12
        return cache
    }()

    static func key(owner: String, data: Data, pretty: Bool) -> String {
        "\(owner)|\(data.count)|\(pretty)"
    }

    static func cached(_ key: String) -> Result? {
        cache.object(forKey: key as NSString)?.result
    }

    static func load(_ data: Data, pretty: Bool, key: String) async -> Result {
        if let cached = cached(key) { return cached }
        let result = await Task.detached(priority: .userInitiated) {
            BodyDocument.make(from: data, pretty: pretty).map(Result.text) ?? .binary
        }.value
        cache.setObject(Entry(result), forKey: key as NSString)
        return result
    }
}
