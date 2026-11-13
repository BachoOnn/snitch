//
//  SidePicker.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct SidePicker: View {
    @Binding var selection: EntrySide

    var body: some View {
        Picker("Side", selection: $selection) {
            ForEach(EntrySide.allCases, id: \.self) { side in
                Text(side.rawValue).tag(side)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .padding(.vertical, Theme.Spacing.spacing10)
        .background(Theme.background)
    }
}
