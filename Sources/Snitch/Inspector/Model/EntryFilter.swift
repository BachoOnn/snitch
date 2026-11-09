import Foundation

/// The timeline's filters. Within a group the choices are combined with OR;
/// the groups (status, method, host, search) are combined with AND.
/// An empty group matches everything.
struct EntryFilter: Equatable {
    /// A range of status codes, such as 200 to 299.
    enum StatusClass: Int, CaseIterable, Hashable {
        case success = 2, redirect, clientError, serverError

        /// The first code in the range, used as its label.
        var label: String { "\(rawValue)00" }

        func contains(_ code: Int) -> Bool { code / 100 == rawValue }
    }

    /// One active filter, shown as a removable chip.
    enum Token: Hashable {
        case statusClass(StatusClass)
        case code(Int)
        case failed
        case pending
        case method(String)
        case host(String)

        var label: String {
            switch self {
            case .statusClass(let statusClass): return statusClass.label
            case .code(let code): return String(code)
            case .failed: return "Failed"
            case .pending: return "Pending"
            case .method(let method): return method
            case .host(let host): return host
            }
        }
    }

    var statusClasses: Set<StatusClass> = []
    /// Exact codes the user typed in, in the order they were added.
    var codes: [Int] = []
    var failed = false
    var pending = false
    var methods: Set<String> = []
    var hosts: Set<String> = []

    var isEmpty: Bool { tokens.isEmpty }

    /// Active filters in display order.
    var tokens: [Token] {
        StatusClass.allCases.filter(statusClasses.contains).map(Token.statusClass)
            + codes.map(Token.code)
            + (failed ? [.failed] : [])
            + (pending ? [.pending] : [])
            + methods.sorted().map(Token.method)
            + hosts.sorted().map(Token.host)
    }

    mutating func remove(_ token: Token) {
        switch token {
        case .statusClass(let statusClass): statusClasses.remove(statusClass)
        case .code(let code): codes.removeAll { $0 == code }
        case .failed: failed = false
        case .pending: pending = false
        case .method(let method): methods.remove(method)
        case .host(let host): hosts.remove(host)
        }
    }

    /// Adds an exact status code. Returns `false` if the text is not a code from 100 to 599.
    @discardableResult
    mutating func addCode(_ text: String) -> Bool {
        guard let code = Int(text.trimmingCharacters(in: .whitespaces)), (100...599).contains(code) else {
            return false
        }
        if !codes.contains(code) { codes.append(code) }
        return true
    }

    func matches(_ entry: NetworkEntry, search: String = "") -> Bool {
        matchesStatus(entry)
            && (methods.isEmpty || methods.contains(entry.method))
            && (hosts.isEmpty || hosts.contains(entry.displayHost))
            && matchesSearch(entry, search)
    }

    private func matchesStatus(_ entry: NetworkEntry) -> Bool {
        if statusClasses.isEmpty && codes.isEmpty && !failed && !pending { return true }
        let outcome = entry.outcome
        if failed && outcome == .failed { return true }
        if pending && outcome == .pending { return true }
        guard let code = entry.statusCode, outcome != .pending else { return false }
        return codes.contains(code) || statusClasses.contains { $0.contains(code) }
    }

    private func matchesSearch(_ entry: NetworkEntry, _ search: String) -> Bool {
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        return [entry.url?.absoluteString ?? "", entry.method, entry.displayStatus]
            .contains { $0.localizedCaseInsensitiveContains(query) }
    }
}
