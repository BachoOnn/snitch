import Foundation

extension NetworkEntry {
    /// A copy with sensitive header values, such as tokens and cookies, redacted.
    /// Used for anything shared to another app, which may pass it on.
    var maskingSensitiveHeaders: NetworkEntry {
        var copy = self
        copy.requestHeaders = SensitiveHeaders.masked(requestHeaders)
        copy.responseHeaders = SensitiveHeaders.masked(responseHeaders)
        return copy
    }
}
