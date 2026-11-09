#if os(iOS)
import SwiftUI

extension Theme {
    /// Monospaced text, used for data such as paths, codes and bodies.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// The wide, heavy face used for the SNITCH title.
    static let title = Font.system(size: 19, weight: .heavy).width(.expanded)

    /// Small uppercase section labels, such as `HEADERS · 6`.
    static let sectionLabel = Font.system(size: 11, weight: .semibold)
}
#endif
