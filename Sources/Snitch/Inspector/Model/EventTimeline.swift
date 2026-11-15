//
//  EventTimeline.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import Foundation

enum EventTimelineItem: Identifiable, Equatable {
    case event(AnalyticsEvent)
    case pause(NetworkStore.Pause)

    var id: UUID {
        switch self {
        case .event(let event): return event.id
        case .pause(let pause): return pause.id
        }
    }

    var date: Date {
        switch self {
        case .event(let event): return event.date
        case .pause(let pause): return pause.start
        }
    }
}

struct EventSection: Identifiable, Equatable {
    let day: Date
    let items: [EventTimelineItem]

    var id: Date { day }

    var events: [AnalyticsEvent] {
        items.compactMap { if case .event(let event) = $0 { return event } else { return nil } }
    }
}
