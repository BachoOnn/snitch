import SwiftUI

extension View {
    /// Keeps a popover as a popover on iPhone (iOS 16.4 and later) instead of a sheet.
    @ViewBuilder
    func compactPopover() -> some View {
        if #available(iOS 16.4, *) {
            presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}
