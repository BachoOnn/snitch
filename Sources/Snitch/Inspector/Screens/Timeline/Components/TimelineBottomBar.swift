//
//  TimelineBottomBar.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct TimelineBottomBar: View {
    @ObservedObject var model: InspectorModel

    @State private var showsFilters = false

    var body: some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            searchField
            filterButton
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.bottom, Theme.Spacing.spacing8)
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.spacing10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.secondary)
            TextField("Search URL, method, status", text: $model.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundStyle(Theme.text)
        }
        .font(.system(size: 16))
        .padding(.horizontal, Theme.Spacing.spacing16)
        .frame(height: Theme.Size.floatingControl)
        .snitchGlass(in: Capsule())
    }

    private var filterButton: some View {
        let activeCount = model.filter.tokens.count
        return Button { showsFilters = true } label: {
            GlassCircle(systemImage: "line.3.horizontal.decrease", badge: activeCount)
        }
        .accessibilityLabel(activeCount == 0 ? "Filters" : "Filters, \(activeCount) active")
        .popover(isPresented: $showsFilters, arrowEdge: .bottom) {
            FilterPanel(filter: $model.filter, methods: model.methods, hosts: model.hosts)
                .compactPopover()
        }
    }
}
