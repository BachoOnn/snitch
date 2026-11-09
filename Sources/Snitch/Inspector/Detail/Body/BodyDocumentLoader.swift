import Foundation

/// Builds body documents in the background and keeps the last few, so switching
/// between request and response, or pretty and raw, is instant the second time.
enum BodyDocumentLoader {
    /// What a body turned out to be.
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

    /// The key for one body shown one way. `owner` names the entry and side.
    static func key(owner: String, data: Data, pretty: Bool) -> String {
        "\(owner)|\(data.count)|\(pretty)"
    }

    /// A document already built for `key`, if any.
    static func cached(_ key: String) -> Result? {
        cache.object(forKey: key as NSString)?.result
    }

    /// Builds the document away from the main thread, or returns the cached one.
    static func load(_ data: Data, pretty: Bool, key: String) async -> Result {
        if let cached = cached(key) { return cached }
        let result = await Task.detached(priority: .userInitiated) {
            BodyDocument.make(from: data, pretty: pretty).map(Result.text) ?? .binary
        }.value
        cache.setObject(Entry(result), forKey: key as NSString)
        return result
    }
}
