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
        var secresult = SecTrustResultType.invalid
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            errSecSuccess == SecTrustEvaluate(serverTrust, &secresult),
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                return
        }
        
        let serverCertificateData = SecCertificateCopyData(serverCertificate)
        let data = CFDataGetBytePtr(serverCertificateData)
        let size = CFDataGetLength(serverCertificateData)
        let cert1 = NSData(bytes: data, length: size)
        for certificatePath in certificatePaths {
            if let cert2 = NSData(contentsOfFile: certificatePath) as Data?,
                cert1.isEqual(to: cert2) {
                completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                                  URLCredential(trust: serverTrust))
                return
            }
        }
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
}

internal class UntrustedURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
