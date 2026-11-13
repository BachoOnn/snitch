//
//  EntrySharing.swift
//  Snitch
//
//  Created by BOniani on 10/11/2026.
//

import Foundation

extension NetworkEntry {
    var maskingSensitiveHeaders: NetworkEntry {
        var copy = self
        copy.requestHeaders = SensitiveHeaders.masked(requestHeaders)
        copy.responseHeaders = SensitiveHeaders.masked(responseHeaders)
        return copy
    }
}
