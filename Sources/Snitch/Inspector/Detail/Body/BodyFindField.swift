import SwiftUI

/// The search field above a body, with the number of matching lines.
struct BodyFindField: View {
    @Binding var query: String
    let matchCount: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Theme.tertiary)
            TextField("Find in body", text: $query)
                .font(.system(size: 13))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Text(matchCount == 1 ? "1 line" : "\(matchCount) lines")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.l)
        .frame(height: Theme.Size.field)
    }
}
