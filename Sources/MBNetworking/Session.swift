//
//  Session.swift
//  Networking
//
//  Created by Rasid Ramazanov on 14.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

class Session {
    
    static let shared = Session()
    
    var session: URLSession
    var delegate: URLSessionDelegate
    
    /// Timeout for requets.
    var timeout: TimeOut {
        didSet {
            self.session.configuration.timeoutIntervalForRequest = timeout.request
            self.session.configuration.timeoutIntervalForResource = timeout.resource
        }
    }
    
    /// SSL certificate paths of `URLSessionDelegate`.
    var certificatePaths: [String] = [] {
        didSet {
            (delegate as? URLSessionPinningDelegate)?.certificatePaths = certificatePaths
        }
    }

    /// Configures networking to trust session authentication challenge, even if the certificate is not trusted.
    func setServerTrustedURLAuthenticationChallenge() {
        let configuration = URLSession.shared.configuration
        self.delegate = UntrustedURLSessionDelegate()
        session = URLSession(configuration: configuration,
                             delegate: delegate,
                             delegateQueue: nil)
    }
    
    required init() {
        let configuration = URLSession.shared.configuration
        timeout = TimeOut(request: 60, resource: 60)
        delegate = URLSessionPinningDelegate()
        self.session = URLSession(configuration: configuration,
                                  delegate: delegate,
                                  delegateQueue: nil)
    }
    
    /// `URLSessionConfiguration` timeout.
    struct TimeOut {
        /// The timeout interval to use when waiting for additional data.
        var request: TimeInterval
        /// The maximum amount of time that a resource request should be allowed to take.
        var resource: TimeInterval
    }
    
}
