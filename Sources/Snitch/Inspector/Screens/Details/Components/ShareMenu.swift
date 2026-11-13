//
//  ShareMenu.swift
//  Snitch
//
//  Created by BOniani on 10/11/2026.
//

import SwiftUI

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
