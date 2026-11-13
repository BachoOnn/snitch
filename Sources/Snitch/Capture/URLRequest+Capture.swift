//
//  URLRequest+Capture.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

extension URLRequest {
    var isHTTP: Bool {
        guard let scheme = url?.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }

    var isForwardedBySnitch: Bool {
        URLProtocol.property(forKey: SnitchURLProtocol.handledKey, in: self) != nil
    }

    func readBody() -> Data? {
        httpBody ?? httpBodyStream?.readAll()
    }

    /// A stream can be read only once, so the body is carried as data.
    func forwardedBySnitch(body: Data?) -> URLRequest {
        let copy = (self as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        if let body, httpBody == nil {
            copy.httpBody = body
        }
        URLProtocol.setProperty(true, forKey: SnitchURLProtocol.handledKey, in: copy)
        return copy as URLRequest
    }

    func withoutSnitchMarker() -> URLRequest {
        let copy = (self as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.removeProperty(forKey: SnitchURLProtocol.handledKey, in: copy)
        return copy as URLRequest
    }
}

extension InputStream {
    func readAll() -> Data {
        open()
        defer { close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while true {
            let count = read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}

extension HTTPURLResponse {
    var stringHeaders: [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in allHeaderFields {
            headers["\(key)"] = "\(value)"
        }
        return headers
    }
}
