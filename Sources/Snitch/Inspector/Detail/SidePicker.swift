import SwiftUI

/// The Request · Response switch pinned above the headers and body.
///
/// A native segmented control, which shows the new selection the moment it is
/// tapped, before the content below has been rebuilt.
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
        .padding(.vertical, Theme.Spacing.m)
        // Opaque so content scrolling under the pinned picker stays hidden.
        .background(Theme.background)
    }
}
