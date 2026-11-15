//
//  InspectorView.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import SwiftUI

struct InspectorView: View {
    @StateObject private var model: InspectorModel
    @StateObject private var events: EventLogModel
    @State private var screen = InspectorScreen.last
    @State private var mounted: Set<InspectorScreen> = [InspectorScreen.last]
    let onClose: () -> Void

    private static let switchAnimation = Animation.spring(response: 0.38, dampingFraction: 0.86)
    /// Long enough for the sheet to finish opening before the other screens are built.
    private static let prepareDelay: UInt64 = 700_000_000

    init(store: NetworkStore = Snitch.store, eventStore: EventStore = Snitch.events, onClose: @escaping () -> Void) {
        _model = StateObject(wrappedValue: InspectorModel(store: store))
        _events = StateObject(wrappedValue: EventLogModel(store: eventStore))
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            root
                .safeAreaInset(edge: .top, spacing: 0) {
                    if screens.count > 1 {
                        LoggerSwitcher(selection: current, screens: screens, count: count, icon: icon, onSelect: select)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .inspectorBarBackground()
                .toolbar {
                    InspectorToolbar(screen: current, screens: screens, count: count, model: model, events: events, onClose: onClose)
                }
        }
        .tint(Theme.text)
        .task { await model.observe() }
        .task { await events.observe() }
        .task { await prepareOtherScreens() }
    }

    private var screens: [InspectorScreen] {
        InspectorScreen.available(sources: events.sources)
    }

    /// The selected screen, or Network if its source is gone.
    private var current: InspectorScreen {
        screens.contains(screen) ? screen : .network
    }

    // Screens stay alive once shown, so switching only animates them in and out.
    private var root: some View {
        let shown = screens.filter { mounted.contains($0) || $0 == current }
        let selectedIndex = screens.firstIndex(of: current) ?? 0
        return ZStack {
            ForEach(shown, id: \.self) { item in
                let index = screens.firstIndex(of: item) ?? 0
                let isCurrent = item == current
                screenView(item)
                    .opacity(isCurrent ? 1 : 0)
                    .offset(x: CGFloat(index - selectedIndex) * Theme.Spacing.switchSlide)
                    .allowsHitTesting(isCurrent)
                    .accessibilityHidden(!isCurrent)
                    .zIndex(isCurrent ? 1 : 0)
            }
        }
    }

    @ViewBuilder
    private func screenView(_ item: InspectorScreen) -> some View {
        switch item {
        case .network:
            TimelineView(model: model)
        case .events(let source):
            EventTimelineView(events: events, network: model, source: source)
        }
    }

    private static let networkLogo = UIImage(named: "NetworkLogo", in: .module, with: nil)

    private func icon(_ item: InspectorScreen) -> UIImage? {
        switch item {
        case .network: return Self.networkLogo
        case .events(let source): return events.icons[source]
        }
    }

    private func count(_ item: InspectorScreen) -> Int {
        switch item {
        case .network: return model.entries.count
        case .events(let source): return events.events(from: source).count
        }
    }

    private func select(_ next: InspectorScreen) {
        guard next != current else { return }
        mounted.insert(next)
        InspectorScreen.last = next
        withAnimation(Self.switchAnimation) { screen = next }
    }

    private func prepareOtherScreens() async {
        try? await Task.sleep(nanoseconds: Self.prepareDelay)
        mounted.formUnion(screens)
    }
}
