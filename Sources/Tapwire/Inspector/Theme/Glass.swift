#if os(iOS)
import SwiftUI

extension View {
    /// Native Liquid Glass on iOS 26 and later; a frosted material on earlier versions.
    @ViewBuilder
    func tapwireGlass<S: Shape>(in shape: S) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26, *) {
            glassEffect(.regular, in: shape)
        } else {
            materialGlass(in: shape)
        }
        #else
        materialGlass(in: shape)
        #endif
    }

    private func materialGlass<S: Shape>(in shape: S) -> some View {
        background(.ultraThinMaterial, in: shape)
            .overlay(shape.stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}

/// A round 52 pt glass button for floating actions, such as filters and copy.
struct GlassCircle: View {
    let systemImage: String
    var badge: Int = 0

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Theme.text)
            .frame(width: 52, height: 52)
            .tapwireGlass(in: Circle())
            .overlay(alignment: .topTrailing) {
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: 0x06210F))
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Theme.accent, in: Capsule())
                        .offset(x: -9, y: 9)
                }
            }
            .contentShape(Circle())
    }
}
#endif
