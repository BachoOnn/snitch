import SwiftUI

extension View {
    /// Native Liquid Glass on iOS 26 and later; a frosted material on earlier versions.
    @ViewBuilder
    func snitchGlass<S: Shape>(in shape: S) -> some View {
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
            .overlay(shape.stroke(Theme.veil(0.10), lineWidth: Theme.Size.hairline))
    }
}
