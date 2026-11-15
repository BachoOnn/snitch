//
//  EventDetailView.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventDetailView: View {
    @ObservedObject var events: EventLogModel
    let id: UUID

    @State private var toast: Toast?

    var body: some View {
        Group {
            if let event = events.event(id: id) {
                content(event)
            } else {
                Text("This event was cleared.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .inspectorBarBackground()
        .toast($toast)
    }

    private func content(_ event: AnalyticsEvent) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventSummaryCard(event: event, icon: events.icons[event.source])
                BodySection(
                    data: event.propertyCount == 0 ? nil : event.properties,
                    size: event.properties.count,
                    owner: event.id.uuidString,
                    name: "Properties",
                    onCopy: copy
                )
                if event.sdkPropertyCount > 0 {
                    HeadersSection(
                        headers: event.sdkProperties,
                        title: "\(event.source) properties",
                        noun: "properties",
                        onCopy: copy
                    )
                    .padding(.top, Theme.Spacing.section)
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.bottom, Theme.Spacing.floatingClearance)
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            DetailCopyButton(accessibilityLabel: "Copy event as JSON") {
                copy(event.copyText, confirmation: "Event copied as JSON")
            }
        }
    }

    private func copy(_ text: String, confirmation: String) {
        Clipboard.copy(text)
        toast = Toast(title: confirmation)
    }
}
