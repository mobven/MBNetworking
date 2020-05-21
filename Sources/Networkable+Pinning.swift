//
//  Networkable+Pinning.swift
//  Networking
//
//  Created by Rasid Ramazanov on 29.01.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation
import Security

internal class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    var certificatePaths: [String] = []
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverCertificate = getServerCertificate(forChallenge: challenge) else {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            return
        }
        let data = CFDataGetBytePtr(serverCertificate.data)
        let size = CFDataGetLength(serverCertificate.data)
        let serverCertificateData = NSData(bytes: data, length: size)
        for certificatePath in certificatePaths {
            if let localCertificateData = NSData(contentsOfFile: certificatePath) as Data?,
                serverCertificateData.isEqual(to: localCertificateData) {
                completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                                  URLCredential(trust: serverCertificate.trust))
                return
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
        forChallenge challenge: URLAuthenticationChallenge) -> (data: CFData, trust: SecTrust)? {
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
    
}

internal class UntrustedURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                          URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
