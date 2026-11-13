//
//  TextShare.swift
//  Snitch
//
//  Created by BOniani on 10/11/2026.
//

import UIKit

@MainActor
enum TextShare {
    static func present(title: String, make: @escaping @Sendable () -> String) {
        guard let top = InspectorPresenter.topViewController() else { return }
        let sheet = UIActivityViewController(activityItems: [Provider(title: title, make: make)], applicationActivities: nil)
        // iPad shows the sheet as a popover, which needs an anchor.
        sheet.popoverPresentationController?.sourceView = top.view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: top.view.bounds.maxX - 44, y: 0, width: 44, height: 44)
        top.present(sheet, animated: true)
    }

    private final class Provider: UIActivityItemProvider, @unchecked Sendable {
        private let title: String
        private let make: @Sendable () -> String

        init(title: String, make: @escaping @Sendable () -> String) {
            self.title = title
            self.make = make
            super.init(placeholderItem: "")
        }

        override var item: Any { make() }

        override func activityViewController(
            _ activityViewController: UIActivityViewController,
            subjectForActivityType activityType: UIActivity.ActivityType?
        ) -> String {
            title
        }
    }
}
