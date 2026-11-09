#if os(iOS)
import SwiftUI

/// The floating bar under the timeline: search plus the filter button and its panel.
struct TimelineBottomBar: View {
    @ObservedObject var model: InspectorModel

    @State private var showsFilters = false

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            searchField
            filterButton
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.bottom, Theme.Spacing.s)
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.m) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.secondary)
            TextField("Search URL, method, status", text: $model.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundStyle(Theme.text)
        }
        .font(.system(size: 16))
        .padding(.horizontal, Theme.Spacing.xxl)
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
#endif
