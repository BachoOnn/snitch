//
//  Forwarder.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

final class Forwarder: NSObject, URLSessionDataDelegate {
    private let lock = NSLock()
    private var owners: [Int: SnitchURLProtocol] = [:]
    private var session: URLSession!

    init(configuration: URLSessionConfiguration) {
        super.init()
        let queue = OperationQueue()
        queue.name = "dev.snitch.forwarder"
        queue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }

    func start(_ request: URLRequest, for owner: SnitchURLProtocol) -> URLSessionDataTask {
        let task = session.dataTask(with: request)
        lock.withLock { owners[task.taskIdentifier] = owner }
        task.resume()
        return task
    }

    private func owner(of task: URLSessionTask) -> SnitchURLProtocol? {
        lock.withLock { owners[task.taskIdentifier] }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        owner(of: dataTask)?.didReceive(response)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        owner(of: dataTask)?.didReceive(data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        owner(of: task)?.willRedirect(response, to: request)
        task.cancel()
        completionHandler(nil)
    }

    // Server trust arrives here too, since there is no session-level handler.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let owner = owner(of: task) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        owner.didReceive(challenge, completionHandler: completionHandler)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let owner = lock.withLock { owners.removeValue(forKey: task.taskIdentifier) }
        owner?.didComplete(error: error)
    }
}
