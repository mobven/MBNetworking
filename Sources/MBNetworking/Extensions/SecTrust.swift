//
//  SecTrust.swift
//
//  MBNetworking
//  Created by Rashid Ramazanov on 4/16/22.
//

import Foundation

public extension Array where Element == SecCertificate {
    var publicKeys: [SecKey] {
        compactMap(\.publicKey)
    }
}

public extension SecCertificate {
    var publicKey: SecKey? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(self, policy, &trust)

        guard let createdTrust = trust, trustCreationStatus == errSecSuccess else { return nil }

        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return SecTrustCopyKey(createdTrust)
        } else {
            return SecTrustCopyPublicKey(createdTrust)
        }
    }
}

public extension SecTrust {
    var certificates: [SecCertificate] {
        if #available(iOS 15, macOS 12, watchOS 8, *) {
            return (SecTrustCopyCertificateChain(self) as? [SecCertificate]) ?? []
        } else {
            return (0 ..< SecTrustGetCertificateCount(self)).compactMap { index in
                SecTrustGetCertificateAtIndex(self, index)
            }
        }
    }
}
