//
//  CappedBody.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

struct CappedBody {
    private(set) var data = Data()
    private(set) var totalSize = 0
    let limit: Int

    init(limit: Int = NetworkEntry.maxStoredBodySize) {
        self.limit = limit
    }

    mutating func append(_ chunk: Data) {
        let room = limit - data.count
        if room > 0 {
            data.append(chunk.prefix(room))
        }
        totalSize += chunk.count
    }
}
