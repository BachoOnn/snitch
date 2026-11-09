import SwiftUI

/// The compact filter panel shown in a popover from the filter button.
struct FilterPanel: View {
    @Binding var filter: EntryFilter
    let methods: [String]
    let hosts: [String]

    private static let width: CGFloat = 264

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterSectionLabel("Status code")
            StatusCodeFilters(filter: $filter)

            FilterDivider()
            FilterSectionLabel("Result")
            ResultFilters(filter: $filter)

            FilterDivider()
            ChoiceMenu(title: "Method", options: methods, selection: filter.methods, onToggle: { filter.toggleMethod($0) })
            ChoiceMenu(title: "Host", options: hosts, selection: filter.hosts, onToggle: { filter.toggleHost($0) })

            FilterDivider()
            resetButton
        }
        .padding(.vertical, Theme.Spacing.xs)
        .frame(width: Self.width)
        .foregroundStyle(Theme.text)
    }

    private var resetButton: some View {
        Button(role: .destructive) { filter = EntryFilter() } label: {
            HStack {
                Text("Reset filters")
                Spacer()
                Image(systemName: "arrow.counterclockwise")
            }
            .font(.system(size: 15))
            .foregroundStyle(Theme.danger)
            .padding(.horizontal, Theme.Spacing.xl)
            .frame(height: Theme.Size.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
