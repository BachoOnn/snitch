#if os(iOS)
import SwiftUI
import UIKit

/// Read-only text the user can select any part of and copy, using the system's
/// selection handles and edit menu. SwiftUI's own text selection only copies whole views.
struct SelectableText: UIViewRepresentable {
    let text: NSAttributedString
    /// Wraps lines to the available width. When `false`, lines keep their length and
    /// the view is as wide as the longest one.
    var wraps = true
    var selectable = true

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.dataDetectorTypes = []
        view.tintColor = UIColor(Theme.accent)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        view.isSelectable = selectable
        view.isUserInteractionEnabled = selectable
        view.textContainer.widthTracksTextView = wraps
        if !wraps {
            view.textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        }
        if view.attributedText != text {
            view.attributedText = text
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        if wraps {
            let width = proposal.width ?? UIView.layoutFittingExpandedSize.width
            let height = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
            return CGSize(width: width, height: ceil(height))
        }
        let bounds = text.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return CGSize(width: ceil(bounds.width) + 1, height: ceil(bounds.height))
    }
}
#endif
