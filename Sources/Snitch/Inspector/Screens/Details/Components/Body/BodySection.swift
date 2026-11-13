//
//  BodySection.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import SwiftUI

struct BodySection: View {
    let data: Data?
    let size: Int
    let owner: String
    var onCopy: (_ text: String, _ confirmation: String) -> Void = { _, _ in }

    @State var pretty = true
    @State var loaded: (key: String, result: BodyDocumentLoader.Result)?
    @State var query = ""
    @State var matches: Set<Int> = []
    @State var search: Task<Void, Never>?

    var body: some View {
        header
            .padding(.top, Theme.Spacing.section)
            .padding(.bottom, Theme.Spacing.spacing8)
            .task(id: key) { await load() }
            .onChange(of: owner) { _ in query = "" }
            .onChange(of: query) { find($0) }
        content
    }

    private var header: some View {
        HStack {
            Text(title).sectionLabelStyle()
            Spacer()
            if case .text(let document)? = result, document.isJSON {
                BodyFormatToggle(pretty: $pretty)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let data, !data.isEmpty {
            switch result {
            case .text(let document)?:
                findBar(document)
                ForEach(document.rows) { row in
                    BodyRowView(row: row, isMatch: matches.contains(row.id))
                }
                footer(storedSize: data.count)
            case .binary?:
                DetailNote("Binary data · \(NetworkEntry.format(bytes: size))")
            case nil:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(Theme.codeBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
            }
        } else {
            DetailNote("No body")
        }
    }

    private func findBar(_ document: BodyDocument) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                BodyFindField(query: $query, matchCount: matches.count)
                CopyChip(accessibilityLabel: "Copy body") { onCopy(document.text, "Body copied") }
                    .padding(.trailing, Theme.Spacing.spacing10)
            }
            Hairline()
        }
        .padding(.bottom, Theme.Spacing.spacing8)
        .background(Theme.codeBackground, in: RoundedCorners(radius: Theme.Radius.card, corners: [.topLeft, .topRight]))
    }

    private func footer(storedSize: Int) -> some View {
        Group {
            if size > storedSize {
                DetailNote("Showing the first \(NetworkEntry.format(bytes: storedSize)) of \(NetworkEntry.format(bytes: size))")
                    .padding(Theme.Spacing.spacing8)
            } else {
                Color.clear.frame(height: Theme.Spacing.spacing10)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Theme.codeBackground, in: RoundedCorners(radius: Theme.Radius.card, corners: [.bottomLeft, .bottomRight]))
    }

    var key: String {
        BodyDocumentLoader.key(owner: owner, data: data ?? Data(), pretty: pretty)
    }

    var result: BodyDocumentLoader.Result? {
        if let loaded, loaded.key == key { return loaded.result }
        return BodyDocumentLoader.cached(key)
    }

    private var title: String {
        guard let data, !data.isEmpty else { return "Body" }
        let kind: String
        switch result {
        case .text(let document)?: kind = document.isJSON ? "JSON · " : "Text · "
        case .binary?: kind = "Binary · "
        case nil: kind = ""
        }
        return "Body · \(kind)\(NetworkEntry.format(bytes: size))"
    }
}
