import SwiftUI

/// The 200 · 300 · 400 · 500 toggles, plus exact codes the user adds.
struct StatusCodeFilters: View {
    @Binding var filter: EntryFilter

    @State private var askingForCode = false
    @State private var codeText = ""

    private static let tileHeight: CGFloat = 46
    private static let dotSize: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            classToggles
            customCodes
        }
        .padding(.horizontal, Theme.Spacing.m)
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
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(EntryFilter.StatusClass.allCases, id: \.self) { statusClass in
                FilterToggleCell(
                    isOn: filter.statusClasses.contains(statusClass),
                    accessibilityLabel: "\(statusClass.label) to \(statusClass.rawValue)99",
                    action: { filter.toggle(statusClass) }
                ) {
                    VStack(spacing: Theme.Spacing.xxs) {
                        Text(statusClass.label).font(Theme.mono(13, .semibold))
                        Circle().fill(statusClass.color).frame(width: Self.dotSize, height: Self.dotSize)
                    }
                    .frame(height: Self.tileHeight)
                }
            }
        }
    }

    private var customCodes: some View {
        FlowLayout(spacing: Theme.Spacing.xs) {
            ForEach(filter.codes, id: \.self) { code in
                customCodeChip(code)
            }
            addCodeButton
        }
    }

    private func customCodeChip(_ code: Int) -> some View {
        Button { filter.remove(.code(code)) } label: {
            HStack(spacing: Theme.Spacing.xxs) {
                Text(String(code)).font(Theme.mono(12, .semibold))
                Image(systemName: "xmark").font(.system(size: 8, weight: .bold))
            }
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, Theme.Spacing.m)
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
                .padding(.horizontal, Theme.Spacing.m)
                .frame(height: Theme.Size.chip)
                .overlay(Capsule().strokeBorder(Theme.veil(0.22), style: StrokeStyle(lineWidth: Theme.Size.hairline, dash: [3, 2])))
        }
        .accessibilityLabel("Add a custom status code")
    }
}

extension EntryFilter.StatusClass {
    /// The dot color shown next to each class.
    var color: Color {
        switch self {
        case .success: return Theme.accent
        case .redirect: return Theme.info
        case .clientError: return Theme.warning
        case .serverError: return Theme.danger
        }
    }
}
