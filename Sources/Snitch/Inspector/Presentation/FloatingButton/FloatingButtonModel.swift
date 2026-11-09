import Foundation

/// Watches the store for the button's pulse and error badge.
@MainActor
final class FloatingButtonModel: ObservableObject {
    /// Changes every time a new request is recorded.
    @Published private(set) var activity = 0
    /// Whether a request failed or returned an error since the inspector was last opened.
    @Published private(set) var hasNewErrors = false

    private var lastSeen = Date()
    private var lastID: UUID?

    init() {
        Task { [weak self] in
            for await entries in Snitch.store.changes() {
                guard let self else { return }
                self.update(entries)
            }
        }
    }

    /// Clears the error badge; called when the inspector opens.
    func markSeen() {
        lastSeen = Date()
        hasNewErrors = false
    }

    private func update(_ entries: [NetworkEntry]) {
        if let last = entries.last?.id, last != lastID {
            lastID = last
            activity += 1
        }
        hasNewErrors = entries.contains { $0.startDate > lastSeen && $0.outcome.isError }
    }
}
