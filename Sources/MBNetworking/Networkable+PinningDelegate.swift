//
//  Networkable+PinningDelegate.swift
//  Networking
//
//  Created by Rasid Ramazanov on 29.01.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation
import Security

protocol URLSessionPinningDelegateProtocol: URLSessionDelegate {
    var certificatePaths: [String] { get set }
}

enum URLSessionPinningComposer {
    static func createDelegate() -> URLSessionPinningDelegateProtocol {
        if #available(iOS 13.0, *) {
            return URLSessionPinningDelegateAsync()
        } else {
            return URLSessionPinningDelegateLegacy()
        }
    }
}

extension URLSessionPinningDelegateProtocol {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didFinishCollecting: metrics)
    }
}

private final class URLSessionPinningDelegateLegacy: NSObject, URLSessionPinningDelegateProtocol {
    var certificatePaths: [String] = []

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let result = URLSessionPinningHelper.processAuthenticationChallenge(
            challenge: challenge,
            certificatePaths: certificatePaths
        )
        completionHandler(result.0, result.1)
    }
}

@available(iOS 13.0, *)
private final class URLSessionPinningDelegateAsync: NSObject, URLSessionPinningDelegateProtocol {
    var certificatePaths: [String] = []

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return URLSessionPinningHelper.processAuthenticationChallenge(
            challenge: challenge,
            certificatePaths: certificatePaths
        )
    }
}

private enum URLSessionPinningHelper {
    static func getServerCertificate(
        forChallenge challenge: URLAuthenticationChallenge
    ) -> (data: CFData, trust: SecTrust)? {
        var secresult = SecTrustResultType.invalid
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              errSecSuccess == SecTrustEvaluate(serverTrust, &secresult),
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        else {
            return nil
        }

        let serverCertificateData = SecCertificateCopyData(serverCertificate)
        return (serverCertificateData, serverTrust)
    }

    static func handleChallengeCommon(
        certificatePaths: [String],
        serverCertificate: (data: CFData, trust: SecTrust)
    ) -> URLSession.AuthChallengeDisposition {
        let serverPublicKeys = serverCertificate.trust.certificates.publicKeys
        for certificatePath in certificatePaths {
            if let localCertificateData = try? Data(contentsOf: URL(fileURLWithPath: certificatePath)) as CFData?,
               let localCertificate = SecCertificateCreateWithData(nil, localCertificateData),
               let localPublicKey = localCertificate.publicKey {
                if serverPublicKeys.contains(localPublicKey) {
                    return .useCredential
                }
            }
        }

        if certificatePaths.isEmpty {
            return .performDefaultHandling
        } else {
            return .cancelAuthenticationChallenge
        }
    }

    static func processAuthenticationChallenge(
        challenge: URLAuthenticationChallenge,
        certificatePaths: [String]
    ) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let serverCertificate = getServerCertificate(forChallenge: challenge) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let disposition = handleChallengeCommon(
            certificatePaths: certificatePaths,
            serverCertificate: serverCertificate
        )

        if disposition == .useCredential {
            return (disposition, URLCredential(trust: serverCertificate.trust))
        } else {
            return (disposition, nil)
        }
    }
}
