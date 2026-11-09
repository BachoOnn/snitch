import SwiftUI

/// A small round copy button, used next to the endpoint and on bodies.
struct CopyChip: View {
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.chip, height: Theme.Size.chip)
                .background(Theme.veil(0.06), in: Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
