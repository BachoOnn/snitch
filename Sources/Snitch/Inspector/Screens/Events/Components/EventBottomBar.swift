//
//  EventBottomBar.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventBottomBar: View {
    @ObservedObject var events: EventLogModel
    let source: String

    @State private var showsFilters = false

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            SearchField(placeholder: "Search event or property", text: $events.search)
            filterButton
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.bottom, Theme.Spacing.spacing8)
    }

    private var filterButton: some View {
        let activeCount = events.activeFilterCount
        return Button { showsFilters = true } label: {
            GlassCircle(systemImage: "line.3.horizontal.decrease", badge: activeCount)
        }
        .accessibilityLabel(activeCount == 0 ? "Filters" : "Filters, \(activeCount) changed")
        .popover(isPresented: $showsFilters, arrowEdge: .bottom) {
            EventFilterPanel(events: events, source: source)
                .compactPopover()
        }
    }
}
