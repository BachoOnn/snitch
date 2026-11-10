import SwiftUI

/// The share button: a menu that opens the system share sheet with the whole
/// exchange or the request as a cURL command. Sensitive header values are redacted.
struct ShareMenu: View {
    let entry: NetworkEntry

    var body: some View {
        Menu {
            Button {
                TextShare.present(title: "Request and response") { [entry] in
                    entry.maskingSensitiveHeaders.reportText
                }
            } label: {
                Label("Request and Response", systemImage: "doc.text")
            }
            Button {
                TextShare.present(title: "cURL command") { [entry] in
                    entry.maskingSensitiveHeaders.curlCommand
                }
            } label: {
                Label("cURL Command", systemImage: "terminal")
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share")
    }
}
