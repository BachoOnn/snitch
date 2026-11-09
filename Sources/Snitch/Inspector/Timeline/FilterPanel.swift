#if os(iOS)
import SwiftUI

/// The compact filter panel shown in a popover from the filter button.
struct FilterPanel: View {
    @Binding var filter: EntryFilter
    let methods: [String]
    let hosts: [String]

    @State private var askingForCode = false
    @State private var codeText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            label("Status code")
            HStack(spacing: 6) {
                ForEach(EntryFilter.StatusClass.allCases, id: \.self) { statusClass in
                    toggleCell(isOn: filter.statusClasses.contains(statusClass), accessibility: "\(statusClass.label) to \(statusClass.rawValue)99") {
                        if filter.statusClasses.contains(statusClass) {
                            filter.statusClasses.remove(statusClass)
                        } else {
                            filter.statusClasses.insert(statusClass)
                        }
                    } content: {
                        VStack(spacing: 5) {
                            Text(statusClass.label).font(Theme.mono(13, .semibold))
                            Circle().fill(color(for: statusClass)).frame(width: 6, height: 6)
                        }
                        .frame(height: 46)
                    }
                }
            }
            .padding(.horizontal, 10)

            FlowLayout(spacing: 6) {
                ForEach(filter.codes, id: \.self) { code in
                    Button { filter.remove(.code(code)) } label: {
                        HStack(spacing: 4) {
                            Text(String(code)).font(Theme.mono(12, .semibold))
                            Image(systemName: "xmark").font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(Theme.accent.opacity(0.08), in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.accent.opacity(0.35)))
                    }
                    .accessibilityLabel("Remove status \(code)")
                }
                Button { askingForCode = true } label: {
                    Label("Code", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textMuted)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .overlay(Capsule().strokeBorder(Theme.veil(0.22), style: StrokeStyle(lineWidth: 1, dash: [3, 2])))
                }
                .accessibilityLabel("Add a custom status code")
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            divider
            label("Result")
            HStack(spacing: 6) {
                toggleCell(isOn: filter.failed, accessibility: "Failed") { filter.failed.toggle() } content: {
                    resultLabel("Failed", dot: Circle().fill(Theme.danger))
                }
                toggleCell(isOn: filter.pending, accessibility: "Pending") { filter.pending.toggle() } content: {
                    resultLabel("Pending", dot: Circle().strokeBorder(Theme.accent, lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 10)

            divider
            choiceMenu("Method", options: methods, selection: $filter.methods)
            choiceMenu("Host", options: hosts, selection: $filter.hosts)
            divider
            Button(role: .destructive) { filter = EntryFilter() } label: {
                HStack {
                    Text("Reset filters")
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                }
                .font(.system(size: 15))
                .foregroundStyle(Theme.danger)
                .padding(.horizontal, 14)
                .frame(height: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .frame(width: 264)
        .foregroundStyle(Theme.text)
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

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Theme.secondary)
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 6)
    }

    private var divider: some View {
        Rectangle().fill(Theme.veil(0.10)).frame(height: 1).padding(.top, 8)
    }

    private func toggleCell<Content: View>(isOn: Bool, accessibility: String, action: @escaping () -> Void, @ViewBuilder content: () -> Content) -> some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity)
                .foregroundStyle(isOn ? Theme.accent : Theme.textMuted)
                .background(isOn ? Theme.accent.opacity(0.10) : Theme.veil(0.04), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(isOn ? Theme.accent.opacity(0.45) : Theme.veil(0.08)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func resultLabel<Dot: View>(_ text: String, dot: Dot) -> some View {
        HStack(spacing: 7) {
            dot.frame(width: 7, height: 7)
            Text(text).font(.system(size: 13, weight: .semibold))
        }
        .frame(height: 38)
    }

    private func choiceMenu(_ title: String, options: [String], selection: Binding<Set<String>>) -> some View {
        Menu {
            if options.isEmpty {
                Text("Nothing captured yet")
            }
            ForEach(options, id: \.self) { option in
                Button {
                    if selection.wrappedValue.contains(option) {
                        selection.wrappedValue.remove(option)
                    } else {
                        selection.wrappedValue.insert(option)
                    }
                } label: {
                    if selection.wrappedValue.contains(option) {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 15))
                Spacer()
                Text(selection.wrappedValue.isEmpty ? "All" : selection.wrappedValue.sorted().joined(separator: ", "))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.secondary)
            }
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
    }

    private func color(for statusClass: EntryFilter.StatusClass) -> Color {
        switch statusClass {
        case .success: return Theme.accent
        case .redirect: return Theme.info
        case .clientError: return Theme.warning
        case .serverError: return Theme.danger
        }
    }
}

extension View {
    /// Keeps a popover as a popover on iPhone (iOS 16.4 and later) instead of a sheet.
    @ViewBuilder
    func compactPopover() -> some View {
        if #available(iOS 16.4, *) {
            presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}
#endif
