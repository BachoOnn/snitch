//
//  InspectorHostingController.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI
import UIKit

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

    private static let onAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark ? color("OnAccent") : .white
    }

    private static func color(_ name: String) -> UIColor {
        UIColor(named: name, in: .module, compatibleWith: nil) ?? .label
    }
}
