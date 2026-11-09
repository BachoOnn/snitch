import SwiftUI

/// A one-point horizontal line between rows.
struct Hairline: View {
    var color: Color = Theme.divider

    var body: some View {
        Rectangle().fill(color).frame(height: Theme.Size.hairline)
    }
}
