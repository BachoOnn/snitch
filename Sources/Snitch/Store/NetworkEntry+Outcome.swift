//
//  NetworkEntry+Outcome.swift
//  Snitch
//
//  Created by BOniani on 05/11/2026.
//

import Foundation

extension NetworkEntry {
    enum Outcome: Equatable {
        case pending
        case success
        case clientError
        case serverError
        case failed

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
