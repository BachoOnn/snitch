#if os(iOS)
import SwiftUI

/// The inspector's first screen: every captured request on one wire, newest first.
struct TimelineView: View {
    @ObservedObject var model: InspectorModel
    let onClose: () -> Void

    @State private var toast: Toast?

    var body: some View {
        let sections = model.sections
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if !model.filter.isEmpty {
                    ActiveFilters(filter: $model.filter)
                        .padding(.bottom, 12)
                }
                if sections.isEmpty {
                    EmptyTimeline(isFiltered: !model.filter.isEmpty || !model.search.isEmpty)
                }
                ForEach(sections) { section in
                    Text(Timeline.title(for: section.day))
                        .sectionLabelStyle()
                        .padding(.vertical, 8)
                    ForEach(section.items) { item in
                        row(for: item)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .toast($toast)
    }

    @ViewBuilder
    private func row(for item: TimelineItem) -> some View {
        switch item {
        case .entry(let entry):
            NavigationLink(value: entry.id) {
                TimelineRow(entry: entry)
                    .background(Theme.background)
            }
            .buttonStyle(.plain)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
            .contextMenu {
                Button {
                    Clipboard.copy(entry.summary)
                    toast = Toast(title: "Copied", detail: "\(entry.method) \(entry.displayPath)")
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        case .pause(let pause):
            PauseDivider(pause: pause)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }
        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("TAPWIRE")
                    .font(Theme.title)
                    .tracking(2)
                    .foregroundStyle(Theme.text)
                HStack(spacing: 6) {
                    Circle()
                        .fill(model.isPaused ? Color.clear : Theme.accent)
                        .overlay(Circle().strokeBorder(Theme.silver, lineWidth: model.isPaused ? 1.5 : 0))
                        .frame(width: 7, height: 7)
                    Text("\(model.entries.count)")
                        .font(Theme.mono(12, .semibold))
                        .foregroundStyle(model.isPaused ? Theme.silver : Color(hex: 0xA9BBB0))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Tapwire, \(model.isPaused ? "paused" : "recording"), \(model.entries.count) requests")
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: model.togglePause) {
                Image(systemName: model.isPaused ? "play.fill" : "pause.fill")
            }
            .accessibilityLabel(model.isPaused ? "Resume recording" : "Pause recording")
            Button(action: model.clear) {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Clear all requests")
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(hex: 0xC9D6CE))
                TextField("Search URL, method, status", text: $model.search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .foregroundStyle(Theme.text)
            }
            .font(.system(size: 16))
            .padding(.horizontal, 18)
            .frame(height: 52)
            .tapwireGlass(in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

/// The active filters as removable chips, under a `FILTERED · N` label.
struct ActiveFilters: View {
    @Binding var filter: EntryFilter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Filtered · \(filter.tokens.count)")
                    .sectionLabelStyle()
                    .foregroundStyle(Theme.tertiary)
                Spacer()
                Button("Clear") { filter = EntryFilter() }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xA9BBB0))
            }
            FlowLayout(spacing: 6) {
                ForEach(filter.tokens, id: \.self) { token in
                    Button { filter.remove(token) } label: {
                        HStack(spacing: 4) {
                            Text(token.label)
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.tertiary)
                        }
                        .font(Theme.mono(11))
                        .foregroundStyle(Color(hex: 0xC3CCC7))
                        .padding(.leading, 10)
                        .padding(.trailing, 8)
                        .frame(height: 28)
                        .background(Color.white.opacity(0.04), in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.09)))
                    }
                    .accessibilityLabel("Remove filter \(token.label)")
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
        }
    }
}

private struct EmptyTimeline: View {
    let isFiltered: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: isFiltered ? "line.3.horizontal.decrease" : "arrow.up.arrow.down")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.tertiary)
                .padding(.bottom, 6)
            Text(isFiltered ? "No matching requests" : "No requests yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text)
            Text(isFiltered ? "Try removing a filter or changing the search." : "Requests your app makes will show up here.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

/// Lays children out in rows, wrapping to a new row when the width runs out.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> [(indices: [Int], width: CGFloat, height: CGFloat)] {
        var rows: [(indices: [Int], width: CGFloat, height: CGFloat)] = []
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if let last = rows.last, last.width + spacing + size.width <= width {
                rows[rows.count - 1] = (last.indices + [index], last.width + spacing + size.width, max(last.height, size.height))
            } else {
                rows.append(([index], size.width, size.height))
            }
        }
        return rows
    }
}
#endif
