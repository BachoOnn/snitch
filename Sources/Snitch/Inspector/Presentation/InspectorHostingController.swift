import SwiftUI
import UIKit

/// Hosts the inspector sheet.
///
/// Native controls inside it, such as the Request · Response switch, get the
/// inspector's brand colors. The styling is scoped to this controller, so the same
/// controls elsewhere in the app keep their own look.
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
        // Only the selection is colored; the track stays native, with Liquid Glass.
        // The brand green is dark in light mode and light in dark mode.
        segmented.selectedSegmentTintColor = color("Accent")
        segmented.setTitleTextAttributes([
            .foregroundColor: color("TextMuted"),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
        ], for: .normal)
        segmented.setTitleTextAttributes([
            .foregroundColor: onAccent,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        ], for: .selected)
    }()

    /// Text on the brand green: white on the dark green, dark on the light green.
    private static let onAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark ? color("OnAccent") : .white
    }

    /// An asset color as a `UIColor` that still follows light and dark mode.
    private static func color(_ name: String) -> UIColor {
        UIColor(named: name, in: .module, compatibleWith: nil) ?? .label
    }
}
