//
//  EventDot.swift
//  Snitch
//
//  Created by BOniani on 15/11/2026.
//

import SwiftUI

struct EventDot: View {
    let isAutomatic: Bool

    var body: some View {
        Circle()
            .fill(isAutomatic ? Theme.background : Theme.accent)
            .overlay(Circle().strokeBorder(Theme.silver, lineWidth: isAutomatic ? 1.5 : 0))
            .frame(width: Theme.Size.eventDot, height: Theme.Size.eventDot)
            .background(Circle().fill(Theme.background).padding(-Theme.Spacing.spacing4))
    }
}
