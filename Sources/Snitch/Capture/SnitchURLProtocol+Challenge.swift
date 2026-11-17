//
//  SnitchURLProtocol+Challenge.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import Foundation

extension SnitchURLProtocol {
    func didReceive(
        _ challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let answer = ChallengeAnswer(completionHandler)
        challengeLock.withLock { pendingChallenge = answer }
        let forwarded = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: answer)
        clientThread?.perform { [self] in
            guard !stopped, let client else {
                return answer.answer(.cancelAuthenticationChallenge, nil)
            }
            client.urlProtocol(self, didReceive: forwarded)
        }
    }
}
