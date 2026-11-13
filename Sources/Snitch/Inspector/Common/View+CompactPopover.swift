//
//  View+CompactPopover.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func compactPopover() -> some View {
        if #available(iOS 16.4, *) {
            presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}
