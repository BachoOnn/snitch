import Foundation
import Testing
@testable import Snitch

struct TimelineTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
    private let noon = Date(timeIntervalSince1970: 1_793_793_600) // 2026-11-04 12:00 UTC

    private func entry(_ offset: TimeInterval, status: Int = 200) -> NetworkEntry {
        var entry = NetworkEntry(url: URL(string: "https://x.test/\(Int(offset))"), method: "GET", startDate: noon.addingTimeInterval(offset))
        entry.statusCode = status
        entry.duration = 0.1
        return entry
    }

    private func pause(_ offset: TimeInterval, length: TimeInterval?) -> NetworkStore.Pause {
        let start = noon.addingTimeInterval(offset)
        return NetworkStore.Pause(id: UUID(), start: start, end: length.map { start.addingTimeInterval($0) })
    }

    @Test func mergesNewestFirstAndGroupsByDay() {
        let yesterday = entry(-86_400)
        let a = entry(10), b = entry(30)
        let gap = pause(20, length: 5)
        let sections = Timeline.sections(entries: [yesterday, a, b], pauses: [gap], filter: EntryFilter(), search: "", calendar: calendar)
        #expect(sections.count == 2)
        #expect(sections[0].items == [.entry(b), .pause(gap), .entry(a)])
        #expect(sections[1].items == [.entry(yesterday)])
    }

    @Test func hidesPausesWhileFilteringOrSearching() {
        var filter = EntryFilter()
        filter.statusClasses = [.serverError]
        let sections = Timeline.sections(entries: [entry(1, status: 500), entry(2)], pauses: [pause(0, length: 1)], filter: filter, search: "", calendar: calendar)
        #expect(sections.flatMap(\.items).count == 1)
        let searched = Timeline.sections(entries: [entry(1)], pauses: [pause(0, length: 1)], filter: EntryFilter(), search: "x.test", calendar: calendar)
        #expect(searched.flatMap(\.items).count == 1)
    }

    @Test func dayTitles() {
        #expect(Timeline.title(for: noon, now: noon, calendar: calendar) == "Today")
        #expect(Timeline.title(for: noon.addingTimeInterval(-86_400), now: noon, calendar: calendar) == "Yesterday")
    }

    @Test func pauseDuration() {
        #expect(pause(0, length: 47).durationText == "47 s")
        #expect(pause(0, length: 185).durationText == "3 min")
        #expect(pause(0, length: nil).durationText == "now")
    }
}
