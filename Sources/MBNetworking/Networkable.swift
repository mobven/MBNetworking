//
//  NetworkEndpoint.swift
//  Networking
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

public protocol Networkable {
    
    /// `URLRequest` of the request.
    var request: URLRequest { get }
    
}

public enum NetworkableConfigs {
    
    case `default`
    
    /// Sets SSL certificate to be used in SSL pinning.
    /// - parameter certificateResourcePaths: Paths of the certificates for ssl pinning.
    public func setCertificatePaths(_ certificateResourcePaths: String...) {
        Session.shared.certificatePaths = certificateResourcePaths
    }
    
    /// Sets timeout for Networkable requests.
    /// - parameter request: The timeout interval to use when waiting for additional data.
    /// - parameter resource: The maximum amount of time that a resource request should be allowed to take.
    public func setTimeout(for request: TimeInterval, resource: TimeInterval) {
        Session.shared.timeout = Session.TimeOut(request: request, resource: resource)
    }
    
}