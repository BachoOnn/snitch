//
//  FloatingButtonWindow.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import UIKit

final class FloatingButtonWindow: UIWindow {
    weak var button: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let button else { return nil }
        // The on-screen frame, so a button still springing back can be tapped.
        let frame = button.layer.presentation()?.frame ?? button.frame
        return frame.contains(point) ? (super.hitTest(point, with: event) ?? button) : nil
    }
}

extension UIWindowScene {
    var appWindow: UIWindow? {
        windows.first { !($0 is FloatingButtonWindow) }
    }
}
