import Foundation

extension URLRequest {
    var isHTTP: Bool {
        guard let scheme = url?.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }

    /// Whether Snitch already forwarded this request, so it must not be captured again.
    var isForwardedBySnitch: Bool {
        URLProtocol.property(forKey: SnitchURLProtocol.handledKey, in: self) != nil
    }

    /// The body, whether it was set directly or as a stream.
    /// URLSession often hands protocols a stream instead of `httpBody`.
    func readBody() -> Data? {
        httpBody ?? httpBodyStream?.readAll()
    }

    /// A copy marked as forwarded, carrying `body` directly since a stream can be read only once.
    func forwardedBySnitch(body: Data?) -> URLRequest {
        let copy = (self as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        if let body, httpBody == nil {
            copy.httpBody = body
        }
        URLProtocol.setProperty(true, forKey: SnitchURLProtocol.handledKey, in: copy)
        return copy as URLRequest
    }

    /// A copy without Snitch's marker, so it can be captured again.
    func withoutSnitchMarker() -> URLRequest {
        let copy = (self as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.removeProperty(forKey: SnitchURLProtocol.handledKey, in: copy)
        return copy as URLRequest
    }
}

extension InputStream {
    /// Reads the whole stream into memory.
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
    /// Response headers as plain strings.
    var stringHeaders: [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in allHeaderFields {
            headers["\(key)"] = "\(value)"
        }
        return headers
    }
}
