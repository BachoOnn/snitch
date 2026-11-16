//
//  EntrySide.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

enum EntrySide: String, CaseIterable {
    case request = "Request"
    case response = "Response"
}

extension NetworkEntry {
    func headers(on side: EntrySide) -> [String: String] {
        side == .request ? requestHeaders : responseHeaders
    }

    func body(on side: EntrySide) -> Data? {
        side == .request ? requestBody : responseBody
    }

    func bodySize(on side: EntrySide) -> Int {
        side == .request ? requestBodySize : responseBodySize
    }

    /// The body as shown on screen: a gzip request body, such as an analytics upload, unzipped.
    func readableBody(on side: EntrySide) -> Data? {
        side == .request ? unzippedRequestBody ?? requestBody : responseBody
    }

    func readableBodySize(on side: EntrySide) -> Int {
        side == .request ? unzippedRequestBody?.count ?? requestBodySize : responseBodySize
    }

    func isUnzipped(on side: EntrySide) -> Bool {
        side == .request && unzippedRequestBody != nil
    }
}
