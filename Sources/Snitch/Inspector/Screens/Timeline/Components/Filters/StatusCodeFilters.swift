//
//  StatusCodeFilters.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct StatusCodeFilters: View {
    @Binding var filter: EntryFilter

    @State private var askingForCode = false
    @State private var codeText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.spacing8) {
            classToggles
            customCodes
        }
        .padding(.horizontal, Theme.Spacing.spacing10)
        .alert("Custom status code", isPresented: $askingForCode) {
            TextField("404", text: $codeText)
                .keyboardType(.numberPad)
            Button("Add") {
                filter.addCode(codeText)
                codeText = ""
            }
            Button("Cancel", role: .cancel) { codeText = "" }
        } message: {
            Text("Any code from 100 to 599")
        }
    }

    private var classToggles: some View {
        HStack(spacing: Theme.Spacing.spacing6) {
            ForEach(EntryFilter.StatusClass.allCases, id: \.self) { statusClass in
                FilterToggleCell(
                    isOn: filter.statusClasses.contains(statusClass),
                    accessibilityLabel: "\(statusClass.label) to \(statusClass.rawValue)99",
                    action: { filter.toggle(statusClass) }
                ) {
                    VStack(spacing: Theme.Spacing.spacing4) {
                        Text(statusClass.label).font(Theme.mono(13, .semibold))
                        Circle().fill(statusClass.color).frame(width: Theme.Size.filterDot, height: Theme.Size.filterDot)
                    }
                    .frame(height: Theme.Size.statusTileHeight)
                }
            }
        }
    }

    private var customCodes: some View {
        FlowLayout(spacing: Theme.Spacing.spacing6) {
            ForEach(filter.codes, id: \.self) { code in
                customCodeChip(code)
            }
            addCodeButton
        }
    }

    private func customCodeChip(_ code: Int) -> some View {
        Button { filter.remove(.code(code)) } label: {
            HStack(spacing: Theme.Spacing.spacing4) {
                Text(String(code)).font(Theme.mono(12, .semibold))
                Image(systemName: "xmark").font(.system(size: 8, weight: .bold))
            }
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, Theme.Spacing.spacing10)
            .frame(height: Theme.Size.chip)
            .background(Theme.accent.opacity(0.08), in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.accent.opacity(0.35)))
        }
        .accessibilityLabel("Remove status \(code)")
    }

    private var addCodeButton: some View {
        Button { askingForCode = true } label: {
            Label("Code", systemImage: "plus")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textMuted)
                .padding(.horizontal, Theme.Spacing.spacing10)
                .frame(height: Theme.Size.chip)
                .overlay(Capsule().strokeBorder(Theme.veil(0.22), style: StrokeStyle(lineWidth: Theme.Size.hairline, dash: [3, 2])))
        }
        .accessibilityLabel("Add a custom status code")
    }
}

extension EntryFilter.StatusClass {
    var color: Color {
        switch self {
        case .success: return Theme.accent
        case .redirect: return Theme.info
        case .clientError: return Theme.warning
        case .serverError: return Theme.danger
        }
    }
}
