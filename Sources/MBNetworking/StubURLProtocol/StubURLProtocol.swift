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
        result != nil
    }
}

public extension StubURLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        isEnabled
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        isEnabled
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Timer.scheduledTimer(withTimeInterval: StubURLProtocol.delay, repeats: false) { [weak self] _ in
            guard let self else { return }
            guard let result = StubURLProtocol.result else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }

            switch result {
            case let .success(data):
                client?.urlProtocol(self, didLoad: data)

                if let url = request.url,
                   let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
                }
            case let .failure(error):
                client?.urlProtocol(self, didFailWithError: error)
            case let .failureStatusCode(statusCode):
                if let url = request.url,
                   let response = HTTPURLResponse(
                       url: url,
                       statusCode: statusCode,
                       httpVersion: nil,
                       headerFields: nil
                   ) {
                    client?.urlProtocol(
                        self,
                        cachedResponseIsValid: CachedURLResponse(response: response, data: Data())
                    )
                }
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        // Nothing to handle
    }
}
