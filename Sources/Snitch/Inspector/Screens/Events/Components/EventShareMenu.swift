//
//  EventShareMenu.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import SwiftUI

struct EventShareMenu: View {
    let event: AnalyticsEvent

    var body: some View {
        Menu {
            Button {
                TextShare.present(title: event.name) { [event] in event.reportText }
            } label: {
                Label("Event", systemImage: "doc.text")
            }
            Button {
                TextShare.present(title: "\(event.name) JSON") { [event] in event.copyText }
            } label: {
                Label("JSON", systemImage: "curlybraces")
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share")
    }
}
