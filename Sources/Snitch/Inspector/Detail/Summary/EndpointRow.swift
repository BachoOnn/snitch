#if os(iOS)
import SwiftUI
import UIKit

/// The selectable host and path, with a button that copies the full URL.
struct EndpointRow: View {
    let entry: NetworkEntry
    let onCopy: () -> Void

    /// The text is drawn from resolved colors, so it is rebuilt when the appearance changes.
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.s) {
            SelectableText(text: endpoint)
                .id(colorScheme)
                .accessibilityLabel(entry.url?.absoluteString ?? "")
            copyButton
        }
    }

    private var copyButton: some View {
        Button(action: onCopy) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondary)
                .frame(width: Theme.Size.chip, height: Theme.Size.chip)
                .background(Theme.veil(0.06), in: Circle())
        }
        .accessibilityLabel("Copy URL")
        // Lines the button up with the first line of text.
        .padding(.top, -5)
    }

    /// Host, dimmed, followed by the path and query.
    private var endpoint: NSAttributedString {
        let font = UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        let text = NSMutableAttributedString(
            string: entry.displayHost,
            attributes: [.font: font, .foregroundColor: UIColor(Theme.tertiary)]
        )
        text.append(NSAttributedString(
            string: entry.displayPath,
            attributes: [.font: font, .foregroundColor: UIColor(Theme.text)]
        ))
        return text
    }
}
#endif
