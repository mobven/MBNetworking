//
//  Session.swift
//  Networking
//
//  Created by Rasid Ramazanov on 14.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

class Session {
    static var instance: Session?
    static var shared: Session {
        guard let instance = instance else {
            self.instance = Session()
            return self.instance!
        }
        return instance
    }

    var session: URLSession
    var delegate: URLSessionDelegate

    var tasksInProgress: [String: URLSessionDataTask] = [:]

    /// Timeout for requets.
    var timeout: TimeOut {
        didSet {
            session.configuration.timeoutIntervalForRequest = timeout.request
            session.configuration.timeoutIntervalForResource = timeout.resource
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
        delegate = UntrustedURLSessionDelegate()
        session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    required init() {
        let configuration = URLSession.shared.configuration
        timeout = TimeOut(request: 60, resource: 60)
        delegate = URLSessionPinningDelegate()
        session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    func setStubProtocolEnabled(_ isEnabled: Bool) {
        let configuration = session.configuration
        if isEnabled {
            URLProtocol.registerClass(StubURLProtocol.self)
            configuration.protocolClasses = [StubURLProtocol.self]
        } else {
            URLProtocol.unregisterClass(StubURLProtocol.self)
            configuration.protocolClasses = nil
        }
        session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    /// `URLSessionConfiguration` timeout.
    struct TimeOut {
        /// The timeout interval to use when waiting for additional data.
        var request: TimeInterval
        /// The maximum amount of time that a resource request should be allowed to take.
        var resource: TimeInterval
    }
}
