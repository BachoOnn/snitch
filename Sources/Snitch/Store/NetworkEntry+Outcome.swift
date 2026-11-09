import Foundation

extension NetworkEntry {
    /// How a request ended, as shown by the inspector's colors and filters.
    enum Outcome: Equatable {
        case pending
        case success
        case clientError
        case serverError
        case failed

        /// Whether the request went wrong: an error status or no response at all.
        var isError: Bool {
            switch self {
            case .clientError, .serverError, .failed: return true
            case .pending, .success: return false
            }
        }
    }

    var outcome: Outcome {
        guard isComplete else { return .pending }
        guard error == nil, let statusCode else { return .failed }
        switch statusCode {
        case ..<400: return .success
        case 400..<500: return .clientError
        default: return .serverError
        }
    }
}
