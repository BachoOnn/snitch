import SwiftUI

/// The trash button. Asks for confirmation before clearing every request.
struct ClearButton: View {
    let count: Int
    let isEnabled: Bool
    let onClear: () -> Void

    @State private var confirming = false

    var body: some View {
        Button { confirming = true } label: {
            Image(systemName: "trash")
        }
        .accessibilityLabel("Clear all requests")
        .disabled(!isEnabled)
        .confirmationDialog(title, isPresented: $confirming, titleVisibility: .visible) {
            Button(confirmTitle, role: .destructive, action: onClear)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("They're removed from Snitch only. Your app isn't affected.")
        }
    }

    private var title: String {
        count == 1 ? "Clear 1 request?" : "Clear all \(count) requests?"
    }

    private var confirmTitle: String {
        count == 1 ? "Clear Request" : "Clear \(count) Requests"
    }
}
