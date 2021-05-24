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

    /// Delay for the response for the current request.
    public static var delay: TimeInterval = 0

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
        Timer.scheduledTimer(withTimeInterval: StubURLProtocol.delay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            guard let result = StubURLProtocol.result else {
                self.client?.urlProtocolDidFinishLoading(self)
                return
            }

            switch result {
            case let .success(data):
                self.client?.urlProtocol(self, didLoad: data)
            case let .failure(error):
                self.client?.urlProtocol(self, didFailWithError: error)
            case let .failureStatusCode(statusCode):
                if let url = self.request.url,
                   let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) {
                    self.client?.urlProtocol(self, cachedResponseIsValid: CachedURLResponse(response: response, data: Data()))
                }
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    public override func stopLoading() {
        // Nothing to handle
    }

}
