//
//  Networkable+UntrustedDelegate.swift
//  Networking
//
//  Created by Umut Can ARDUÇ on 9.08.2024.
//  Copyright © 2024 Mobven. All rights reserved.
//

import Foundation

enum UntrustedURLSessionComposer {
    static func createDelegate() -> URLSessionDelegate {
        if #available(iOS 13.0, *) {
            UntrustedURLSessionDelegateAsync()
        } else {
            UntrustedURLSessionDelegate()
        }
    }
}

@available(iOS 13.0, *) class UntrustedURLSessionDelegateAsync: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

class UntrustedURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
