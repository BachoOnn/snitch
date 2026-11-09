import SwiftUI

/// The Request · Response switch pinned above the headers and body.
///
/// A native segmented control, so it gets the system's Liquid Glass and shows the
/// new selection the moment it is tapped. Its colors come from
/// ``InspectorHostingController``.
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
