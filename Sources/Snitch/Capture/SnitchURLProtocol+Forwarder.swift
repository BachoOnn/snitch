//
//  SnitchURLProtocol+Forwarder.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

/// Callbacks from the forwarder, delivered on its serial delegate queue.
extension SnitchURLProtocol {
    func didReceive(_ response: URLResponse) {
        guard !finished else { return }
        if let http = response as? HTTPURLResponse {
            record(http)
        }
        onClient { $0.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed) }
    }

    func didReceive(_ data: Data) {
        guard !finished else { return }
        responseBody.append(data)
        onClient { $0.urlProtocol(self, didLoad: data) }
    }

    func willRedirect(_ response: HTTPURLResponse, to newRequest: URLRequest) {
        guard !finished else { return }
        record(response)
        complete(error: nil)

        let redirect = newRequest.withoutSnitchMarker()
        onClient {
            $0.urlProtocol(self, wasRedirectedTo: redirect, redirectResponse: response)
            $0.urlProtocol(self, didFailWithError: CocoaError(.userCancelled))
        }
    }

    func didComplete(error: Error?) {
        guard !finished else { return }
        complete(error: error)
        onClient { client in
            if let error {
                client.urlProtocol(self, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(self)
            }
        }
    }

    func complete(error: Error?) {
        finished = true
        let duration = ProcessInfo.processInfo.systemUptime - startUptime
        let body = responseBody
        record {
            $0.responseBody = body.data.isEmpty ? nil : body.data
            $0.responseBodySize = body.totalSize
            $0.error = error.map(Self.describe)
            $0.duration = duration
        }
    }

    func record(_ response: HTTPURLResponse) {
        record {
            $0.statusCode = response.statusCode
            $0.responseHeaders = response.stringHeaders
        }
    }
}
