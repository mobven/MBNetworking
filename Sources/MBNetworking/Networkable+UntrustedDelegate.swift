//
//  Networkable+UntrustedDelegate.swift
//  Networking
//
//  Created by Umut Can ARDUÇ on 9.08.2024.
//  Copyright © 2024 Mobven. All rights reserved.
//

import Foundation

func createUntrustedURLSessionDelegate() -> URLSessionDelegate {
    if #available(iOS 13.0, *) {
        return UntrustedURLSessionDelegateAsync()
    } else {
        return UntrustedURLSessionDelegateLegacy()
    }
}

@available(iOS 13.0, *)
class UntrustedURLSessionDelegateAsync: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


class UntrustedURLSessionDelegateLegacy: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
