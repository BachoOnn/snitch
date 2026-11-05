import Foundation

/// One row of the timeline: a request or a pause gap.
enum TimelineItem: Identifiable, Equatable {
    case entry(NetworkEntry)
    case pause(NetworkStore.Pause)

    var id: UUID {
        switch self {
        case .entry(let entry): return entry.id
        case .pause(let pause): return pause.id
        }
    }

    var date: Date {
        switch self {
        case .entry(let entry): return entry.startDate
        case .pause(let pause): return pause.start
        }
    }
}

/// A day's worth of timeline rows, newest first.
struct TimelineSection: Identifiable, Equatable {
    let day: Date
    let items: [TimelineItem]

    var id: Date { day }
}

enum Timeline {
    /// Builds the timeline, newest first and grouped by day. Pause gaps are shown only
    /// when nothing is filtered or searched, since they are not requests.
    static func sections(
        entries: [NetworkEntry],
        pauses: [NetworkStore.Pause],
        filter: EntryFilter,
        search: String,
        calendar: Calendar = .current
    ) -> [TimelineSection] {
        let showsPauses = filter.isEmpty && search.trimmingCharacters(in: .whitespaces).isEmpty
        let items = entries.filter { filter.matches($0, search: search) }.map(TimelineItem.entry)
            + (showsPauses ? pauses.map(TimelineItem.pause) : [])
        let sorted = items.sorted { $0.date > $1.date }

        var sections: [TimelineSection] = []
        for item in sorted {
            let day = calendar.startOfDay(for: item.date)
            if let last = sections.last, last.day == day {
                sections[sections.count - 1] = TimelineSection(day: day, items: last.items + [item])
            } else {
                sections.append(TimelineSection(day: day, items: [item]))
            }
        }
        return sections
    }

    /// `Today`, `Yesterday`, or a short date.
    static func title(for day: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDate(day, inSameDayAs: now) { return "Today" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(day, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        return day.formatted(.dateTime.month(.abbreviated).day())
    }
}

extension NetworkStore.Pause {
    /// How long the pause lasted, such as `47 s` or `3 min`, or `now` while it is in progress.
    var durationText: String {
        guard let end else { return "now" }
        let seconds = Int(end.timeIntervalSince(start).rounded())
        return seconds < 60 ? "\(seconds) s" : "\(seconds / 60) min"
    }
}
