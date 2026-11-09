import SwiftUI

/// A short message in place of missing content, such as "No body".
struct DetailNote: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(Theme.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.xl)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}
