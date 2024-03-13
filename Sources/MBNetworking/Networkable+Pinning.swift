//
//  Networkable+Pinning.swift
//  Networking
//
//  Created by Rasid Ramazanov on 29.01.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation
import Security

internal class URLSessionPinningDelegate: NSObject, URLSessionTaskDelegate {
    var certificatePaths: [String] = []

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverCertificate = getServerCertificate(forChallenge: challenge) else {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            return
        }

        let serverPublicKeys = serverCertificate.trust.certificates.publicKeys
        for certificatePath in certificatePaths {
            if let localCertificateData = try? Data(contentsOf: URL(fileURLWithPath: certificatePath)) as CFData?,
               let localCertificate = SecCertificateCreateWithData(nil, localCertificateData),
               let localPublicKey = localCertificate.publicKey {
                if serverPublicKeys.contains(localPublicKey) {
                    completionHandler(
                        URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverCertificate.trust)
                    )
                    return
                }
            }
        }
        if certificatePaths.count == 0 {
            // No SSL pinning. Performing default handling.
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        } else {
            // SSL pinning could not succeed with given certificates. Cancelling authentication.
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
    }

    private func getServerCertificate(
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

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didFinishCollecting: metrics)
    }
}

internal class UntrustedURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(
            URLSession.AuthChallengeDisposition.useCredential,
            URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }
}
