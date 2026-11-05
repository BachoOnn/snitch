#if os(iOS)
import SwiftUI
import UIKit

/// Copies text to the clipboard with a light haptic.
enum Clipboard {
    @MainActor
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// A short confirmation shown at the top of a screen, such as `Copied`.
struct Toast: Equatable {
    var title: String
    var detail: String?
}

private struct ToastOverlay: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.accent)
                    Text(toast.title)
                        .font(.system(size: 14, weight: .semibold))
                    if let detail = toast.detail {
                        Text(detail)
                            .font(Theme.mono(12))
                            .foregroundStyle(Theme.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .tapwireGlass(in: Capsule())
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .task(id: toast) {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    withAnimation { self.toast = nil }
                }
            }
        }
        .animation(.spring(duration: 0.3), value: toast)
    }
}

extension View {
    /// Shows `toast` briefly, then clears it.
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastOverlay(toast: toast))
    }
}
#endif
