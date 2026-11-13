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
}
