import SwiftUI

/// The card at the top of the detail screen: status, endpoint, error, and timing.
struct SummaryCard: View {
    let entry: NetworkEntry
    /// Copies text and shows a confirmation.
    let onCopy: (_ text: String, _ confirmation: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            status
            EndpointRow(entry: entry) {
                onCopy(entry.url?.absoluteString ?? "", "URL copied")
            }
            if let error = entry.error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.danger)
            }
            SummaryMetrics(entry: entry)
        }
        .padding(Theme.Spacing.xl)
        .cardStyle(radius: Theme.Radius.panel)
        .accessibilityElement(children: .contain)
    }

    private var status: some View {
        HStack(spacing: Theme.Spacing.m) {
            MethodPill(method: entry.method, outcome: entry.outcome)
            Text(entry.displayStatus)
                .font(Theme.mono(20, .bold))
                .foregroundStyle(entry.outcome == .pending ? Theme.secondary : Theme.color(for: entry.outcome))
            if let phrase = entry.reasonPhrase, entry.outcome != .failed {
                Text(phrase)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondary)
            }
        }
    }
}
