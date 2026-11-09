import SwiftUI

/// A request or response body: pretty or raw, with find and line numbers.
///
/// The section is a list of separate views rather than one container, so inside the
/// detail screen's lazy stack only the rows on screen are built. That keeps even a
/// body of tens of thousands of lines quick to open and scroll.
struct BodySection: View {
    let data: Data?
    /// The full size, which can be larger than `data` when the body was truncated.
    let size: Int
    /// Names the entry and side, so built documents can be reused.
    let owner: String
    /// Copies text and shows a confirmation.
    var onCopy: (_ text: String, _ confirmation: String) -> Void = { _, _ in }

    @State private var pretty = true
    @State private var loaded: (key: String, result: BodyDocumentLoader.Result)?
    @State private var query = ""
    @State private var matches: Set<Int> = []
    @State private var search: Task<Void, Never>?

    var body: some View {
        header
            .padding(.top, Theme.Spacing.section)
            .padding(.bottom, Theme.Spacing.s)
            .task(id: key) { await load() }
            .onChange(of: owner) { _ in query = "" }
            .onChange(of: query) { find($0) }
        content
    }

    // MARK: - Parts

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
                    .padding(.trailing, Theme.Spacing.m)
            }
            Hairline()
        }
        .padding(.bottom, Theme.Spacing.s)
        .background(Theme.codeBackground, in: RoundedCorners(radius: Theme.Radius.card, corners: [.topLeft, .topRight]))
    }

    private func footer(storedSize: Int) -> some View {
        Group {
            if size > storedSize {
                DetailNote("Showing the first \(NetworkEntry.format(bytes: storedSize)) of \(NetworkEntry.format(bytes: size))")
                    .padding(Theme.Spacing.s)
            } else {
                Color.clear.frame(height: Theme.Spacing.m)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Theme.codeBackground, in: RoundedCorners(radius: Theme.Radius.card, corners: [.bottomLeft, .bottomRight]))
    }

    // MARK: - Loading and find

    private var key: String {
        BodyDocumentLoader.key(owner: owner, data: data ?? Data(), pretty: pretty)
    }

    /// The document for the current side and format: just loaded, or already cached.
    private var result: BodyDocumentLoader.Result? {
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

    private func load() async {
        guard let data, !data.isEmpty else { return }
        let key = key
        let result = await BodyDocumentLoader.load(data, pretty: pretty, key: key)
        guard !Task.isCancelled else { return }
        loaded = (key, result)
        find(query)
    }

    /// Finds rows matching `text` in the background, after a short pause in typing.
    /// A result is only kept if `text` is still what the field holds.
    private func find(_ text: String) {
        search?.cancel()
        guard case .text(let document)? = result,
              !text.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            matches = []
            return
        }
        search = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            let found = await Task.detached(priority: .userInitiated) { document.rows(matching: text) }.value
            guard !Task.isCancelled, text == query else { return }
            matches = found
        }
    }
}
