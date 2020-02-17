//
//  Session.swift
//  Networking
//
//  Created by Rasid Ramazanov on 14.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

class Session {
    
    private static var session: Session!
    
    class func shared(certificatePath: String? = nil) -> Session {
        guard self.session == nil else { return session }
        let session = Session(certificatePath: certificatePath)
        self.session = session
        return session
    }
    
    var session: URLSession
    var delegate: URLSessionDelegate
    
    var timeout: TimeOut {
        didSet {
            self.session.configuration.timeoutIntervalForRequest = timeout.request
            self.session.configuration.timeoutIntervalForResource = timeout.resource
        }
    }
    
    required init(certificatePath: String? = nil) {
        let configuration = URLSession.shared.configuration
        timeout = TimeOut(request: 30, resource: 30)
        delegate = URLSessionPinningDelegate(certificatePath: certificatePath)
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
