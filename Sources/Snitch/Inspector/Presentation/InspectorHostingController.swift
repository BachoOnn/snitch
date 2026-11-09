import SwiftUI
import UIKit

/// Hosts the inspector sheet.
///
/// Native controls inside it, such as the Request · Response switch, are restyled
/// to match the inspector's colors. The styling is scoped to this controller, so the
/// same controls elsewhere in the app keep their own look.
final class InspectorHostingController: UIHostingController<InspectorView> {
    override init(rootView: InspectorView) {
        _ = Self.styleControls
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private static let styleControls: Void = {
        let segmented = UISegmentedControl.appearance(whenContainedInInstancesOf: [InspectorHostingController.self])
        // Close to the page background, with a light brand fill for the selection, so the
        // switch sits quietly on the page in both light and dark mode.
        segmented.backgroundColor = color("CodeBackground")
        segmented.selectedSegmentTintColor = color("AccentFill").withAlphaComponent(0.6)
        segmented.setTitleTextAttributes([
            .foregroundColor: color("TextMuted"),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
        ], for: .normal)
        segmented.setTitleTextAttributes([
            .foregroundColor: color("Text"),
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        ], for: .selected)
    }()

    /// An asset color as a `UIColor` that still follows light and dark mode.
    private static func color(_ name: String) -> UIColor {
        UIColor(named: name, in: .module, compatibleWith: nil) ?? .label
    }
}
