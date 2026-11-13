//
//  NetworkEntry.swift
//  Snitch
//
//  Created by BOniani on 04/11/2026.
//

import Foundation

/// One HTTP request and its response, as captured by Snitch.
///
/// An entry is recorded as soon as the request starts and is updated when it
/// completes, fails, or is cancelled. Use ``isComplete`` to tell the two apart.
public struct NetworkEntry: Identifiable, Equatable, Sendable {
    static let maxStoredBodySize = 1_048_576

    /// A unique identifier for this entry.
    public let id: UUID
    /// The request URL.
    public internal(set) var url: URL?
    /// The HTTP method, such as `GET` or `POST`.
    public internal(set) var method: String
    /// The request headers as sent by the app.
    public internal(set) var requestHeaders: [String: String]
    /// The request body, truncated to 1 MB. `nil` when the request has no body.
    public internal(set) var requestBody: Data?
    /// The full size of the request body in bytes.
    public internal(set) var requestBodySize: Int
    /// The HTTP status code, or `nil` if no response has arrived.
    public internal(set) var statusCode: Int?
    /// The response headers.
    public internal(set) var responseHeaders: [String: String]
    /// The response body, truncated to 1 MB. Set when the request completes; `nil` if no body arrived.
    public internal(set) var responseBody: Data?
    /// The full size of the response body in bytes. Set when the request completes.
    public internal(set) var responseBodySize: Int
    /// When the request started.
    public internal(set) var startDate: Date
    /// Time from start to completion, or `nil` while the request is in flight.
    public internal(set) var duration: TimeInterval?
    /// A description of the error if the request failed or was cancelled.
    public internal(set) var error: String?

    /// Whether the request has finished, successfully or not.
    public var isComplete: Bool { duration != nil }

    init(
        id: UUID = UUID(),
        url: URL?,
        method: String,
        requestHeaders: [String: String] = [:],
        requestBody: Data? = nil,
        startDate: Date = Date()
    ) {
        self.id = id
        self.url = url
        self.method = method
        self.requestHeaders = requestHeaders
        let body = requestBody?.isEmpty == false ? requestBody : nil
        self.requestBody = body.map { $0.prefix(Self.maxStoredBodySize) }
        self.requestBodySize = body?.count ?? 0
        self.statusCode = nil
        self.responseHeaders = [:]
        self.responseBody = nil
        self.responseBodySize = 0
        self.startDate = startDate
        self.duration = nil
        self.error = nil
    }
}

/// Keeps headers, bodies and query strings out of `print`, interpolation and logs.
extension NetworkEntry: CustomStringConvertible, CustomDebugStringConvertible {
    /// A short summary such as `GET api.example.com/users 200`, without query, headers, or bodies.
    public var description: String {
        let target = url.map { ($0.host ?? "") + $0.path } ?? "?"
        let outcome = statusCode.map(String.init) ?? (error == nil ? "pending" : "failed")
        return "\(method) \(target) \(outcome)"
    }

    /// Same as ``description``.
    public var debugDescription: String { description }
}
