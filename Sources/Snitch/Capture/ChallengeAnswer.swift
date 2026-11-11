import Foundation

/// Carries the app's answer to a forwarded challenge back to the forwarding session.
/// The first answer wins; later ones are ignored.
final class ChallengeAnswer: NSObject, URLAuthenticationChallengeSender, @unchecked Sendable {
    typealias Handler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    private let lock = NSLock()
    private var handler: Handler?

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    func answer(_ disposition: URLSession.AuthChallengeDisposition, _ credential: URLCredential?) {
        let handler = lock.withLock {
            defer { self.handler = nil }
            return self.handler
        }
        handler?(disposition, credential)
    }

    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        answer(.useCredential, credential)
    }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        answer(.useCredential, nil)
    }

    func cancel(_ challenge: URLAuthenticationChallenge) {
        answer(.cancelAuthenticationChallenge, nil)
    }

    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        answer(.performDefaultHandling, nil)
    }

    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        answer(.rejectProtectionSpace, nil)
    }
}
