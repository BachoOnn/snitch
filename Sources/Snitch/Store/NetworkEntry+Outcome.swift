import Foundation

extension NetworkEntry {
    /// How a request ended, as shown by the inspector's colors and filters.
    enum Outcome: Equatable {
        case pending
        case success
        case clientError
        case serverError
        case failed
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
