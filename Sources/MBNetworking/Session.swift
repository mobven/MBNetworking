//
//  Session.swift
//  Networking
//
//  Created by Rasid Ramazanov on 14.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

final class Session {
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
    var timeout = TimeOut(request: 60, resource: 60) {
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

    /// `URLSessionConfiguration` for initiating `URLSession`.
    /// Default value is `URLSessionConfiguration.default` which can be set to `URLSessionConfiguration.ephemeral`.
    var configuration = URLSessionConfiguration.default {
        didSet {
            session = URLSession(
                configuration: configuration,
                delegate: delegate,
                delegateQueue: nil
            )
        }
    }

    /// Configures networking to trust session authentication challenge, even if the certificate is not trusted.
    func setServerTrustedURLAuthenticationChallenge() {
        delegate = UntrustedURLSessionDelegate()
        session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    required init() {
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
