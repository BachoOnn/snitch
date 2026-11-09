import Foundation

/// A body collected in chunks: keeps at most `limit` bytes, but counts them all.
struct CappedBody {
    private(set) var data = Data()
    /// The full size of everything appended, including bytes past the limit.
    private(set) var totalSize = 0
    let limit: Int

    init(limit: Int = NetworkEntry.maxStoredBodySize) {
        self.limit = limit
    }

    mutating func append(_ chunk: Data) {
        let room = limit - data.count
        if room > 0 {
            data.append(chunk.prefix(room))
        }
        totalSize += chunk.count
    }
}
