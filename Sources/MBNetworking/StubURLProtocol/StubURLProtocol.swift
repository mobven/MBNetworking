//
//  StubURLProtocol.swift
//  Networking
//
//  Created by Rashid Ramazanov on 15.02.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation
import MBErrorKit

/// URLProtocol for simplifying unit tests by acting man-in-the-middle on for the session.
/// It's configured to work only with test targets. It won't work if there's no test process in progress.
public final class StubURLProtocol: URLProtocol {

    /// Result of the request, which is going to happen.
    public static var result: Result? {
        didSet {
            if result == nil {
                Session.shared.setStubProtocolEnabled(false)
            } else {
                if ProcessInfo.isUnderTest {
                    Session.shared.setStubProtocolEnabled(true)
                }
            }
        }
    }

    static var isEnabled: Bool {
        return result != nil
    }

}

extension StubURLProtocol {

    public override class func canInit(with request: URLRequest) -> Bool {
        return isEnabled
    }

    public override class func canInit(with task: URLSessionTask) -> Bool {
        return isEnabled
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        guard let result = StubURLProtocol.result else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        switch result {
        case let .success(data):
            client?.urlProtocol(self, didLoad: data)
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        case let .failureStatusCode(statusCode):
            if let url = request.url,
               let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) {
                client?.urlProtocol(self, cachedResponseIsValid: CachedURLResponse(response: response, data: Data()))
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {
        // Nothing to handle
    }

}
