import Foundation
import Testing
@testable import Tapwire

/// Each test uses its own store, so this suite can run in parallel.
struct NetworkStoreTests {
    private func make(_ path: String) -> NetworkEntry {
        NetworkEntry(url: URL(string: "https://example.test/\(path)"), method: "GET")
    }

    @Test func keepsInsertionOrder() {
        let store = NetworkStore()
        let items = (0..<3).map { make("\($0)") }
        items.forEach(store.insert)
        #expect(store.entries.map(\.id) == items.map(\.id))
    }

    @Test(arguments: [(1, 5), (3, 5), (5, 5), (10, 5)])
    func dropsOldestWhenFull(maxCount: Int, inserted: Int) {
        let store = NetworkStore(maxCount: maxCount)
        let items = (0..<inserted).map { make("\($0)") }
        items.forEach(store.insert)
        #expect(store.entries.map(\.id) == items.suffix(maxCount).map(\.id))
    }

    @Test func defaultLimitIs500() {
        let store = NetworkStore()
        for i in 0..<510 { store.insert(make("\(i)")) }
        #expect(store.maxCount == 500)
        #expect(store.entries.count == 500)
        #expect(store.entries.first?.url?.lastPathComponent == "10")
    }

    @Test func updateReplacesInPlace() {
        let store = NetworkStore()
        var first = make("a")
        store.insert(first)
        store.insert(make("b"))
        first.statusCode = 204
        store.update(first)
        #expect(store.entries.map(\.statusCode) == [204, nil])
    }

    @Test func updateIgnoresDroppedEntry() {
        let store = NetworkStore(maxCount: 1)
        var dropped = make("a")
        store.insert(dropped)
        store.insert(make("b"))
        dropped.statusCode = 200
        store.update(dropped)
        #expect(store.entries.map(\.url?.lastPathComponent) == ["b"])
    }

    @Test func clear() {
        let store = NetworkStore()
        store.insert(make("a"))
        store.clear()
        #expect(store.entries.isEmpty)
    }

    @Test func changesStreamsSnapshots() async {
        let store = NetworkStore()
        store.insert(make("a"))
        var iterator = store.changes().makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial?.count == 1)

        store.insert(make("b"))
        let next = await iterator.next()
        #expect(next?.map(\.url?.lastPathComponent) == ["a", "b"])
    }

    @Test func concurrentInsertsAreSafe() {
        let store = NetworkStore(maxCount: 1000)
        DispatchQueue.concurrentPerform(iterations: 800) { i in
            store.insert(make("\(i)"))
        }
        #expect(store.entries.count == 800)
    }

    @Test func truncatesLargeBodiesButKeepsSize() {
        let body = Data(count: NetworkEntry.maxStoredBodySize + 10)
        let entry = NetworkEntry(url: nil, method: "POST", requestBody: body)
        #expect(entry.requestBody?.count == NetworkEntry.maxStoredBodySize)
        #expect(entry.requestBodySize == body.count)
    }

    @Test func emptyRequestBodyIsNil() {
        let entry = NetworkEntry(url: nil, method: "POST", requestBody: Data())
        #expect(entry.requestBody == nil)
        #expect(entry.requestBodySize == 0)
    }

    @Test func descriptionHidesSensitiveParts() {
        var entry = NetworkEntry(
            url: URL(string: "https://api.example.test/users?token=secret"),
            method: "POST",
            requestHeaders: ["Authorization": "Bearer secret"],
            requestBody: Data("password=secret".utf8)
        )
        #expect(entry.description == "POST api.example.test/users pending")
        entry.statusCode = 201
        #expect("\(entry)" == "POST api.example.test/users 201")
        #expect(!String(reflecting: entry).contains("secret"))
    }
}
