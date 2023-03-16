//
//  NetworkableConfigs.swift
//  MBNetworking
//
//  Created by Rashid Ramazanov on 9/30/21.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

public enum NetworkableConfigs {
    case `default`

    /// Sets SSL certificate to be used in SSL pinning.
    /// - parameter certificateResourcePaths: Paths of the certificates for ssl pinning.
    public func setCertificatePaths(_ certificateResourcePaths: String...) {
        setCertificatePathArray(certificateResourcePaths)
    }

    /// Sets SSL certificate to be used in SSL pinning.
    /// - parameter certificateResourcePaths: Paths of the certificates for ssl pinning.
    public func setCertificatePathArray(_ certificateResourcePaths: [String]) {
        Session.shared.certificatePaths = certificateResourcePaths
    }

    /// Sets timeout for Networkable requests.
    /// - parameter request: The timeout interval to use when waiting for additional data.
    /// - parameter resource: The maximum amount of time that a resource request should be allowed to take.
    public func setTimeout(for request: TimeInterval, resource: TimeInterval) {
        Session.shared.timeout = Session.TimeOut(request: request, resource: resource)
    }

    /// Configures networking to trust session authentication challenge, even if the certificate is not trusted.
    /// **Apple may reject your application, for this usage. It's on your own responsibility**
    public func setServerTrustedURLAuthenticationChallenge() {
        Session.shared.setServerTrustedURLAuthenticationChallenge()
    }

    /// Sets `URLSessionConfiguration` for initiating `URLSession`.
    /// Default value is `URLSessionConfiguration.default` which can be set to `URLSessionConfiguration.ephemeral`.
    /// - Parameter configuration: URLSessionConfiguration.
    public func set(configuration: URLSessionConfiguration) {
        Session.shared.configuration = configuration
    }
}
