import UIKit

/// Copies text to the clipboard with a light haptic.
enum Clipboard {
    @MainActor
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
