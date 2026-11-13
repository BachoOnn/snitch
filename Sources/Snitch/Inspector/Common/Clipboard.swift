//
//  Clipboard.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import UIKit

enum Clipboard {
    @MainActor
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
