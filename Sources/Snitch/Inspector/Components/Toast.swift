import SwiftUI

/// A short confirmation shown at the top of a screen, such as `Copied`.
struct Toast: Equatable {
    var title: String
    var detail: String?
}

extension View {
    /// Shows `toast` briefly, then clears it.
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastPresenter(toast: toast))
    }
}

private struct ToastPresenter: ViewModifier {
    @Binding var toast: Toast?

    private static let visibleFor: UInt64 = 1_600_000_000

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .task(id: toast) {
                            try? await Task.sleep(nanoseconds: Self.visibleFor)
                            withAnimation { self.toast = nil }
                        }
                }
            }
            .animation(.spring(duration: 0.3), value: toast)
    }
}

private struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: Theme.Spacing.s) {
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
        .padding(.horizontal, Theme.Spacing.xl)
        .frame(height: Theme.Size.field)
        .snitchGlass(in: Capsule())
        .padding(.horizontal, Theme.Spacing.xxxl)
        .padding(.top, Theme.Spacing.s)
        .accessibilityElement(children: .combine)
    }
}
