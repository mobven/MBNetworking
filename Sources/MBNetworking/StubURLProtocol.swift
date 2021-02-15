//
//  StubURLProtocol.swift
//  Networking
//
//  Created by Rashid Ramazanov on 15.02.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation
import MBErrorKit

/// URLProtocol for simplifying Networking tests.
public final class StubURLProtocol: URLProtocol {

    /// Result of the request is going to happen.
    public static var result: Result?

    static var isEnabled: Bool {
        return result != nil
    }

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

extension StubURLProtocol {

    public enum Result {

        /// Successfull result with specified data
        case success(Data)
        /// Failure with the specified Error.
        /// The  actual result will from `Networkable.fetch` will be `NetworkingError.underlyingError`.
        case failure(Error)
        /// Failure with the specified status code.
        /// The  actual result will from `Networkable.fetch` will be `NetworkingError.httpError`.
        case failureStatusCode(Int)

    }

}

extension StubURLProtocol.Result {

    static func getData(from path: URL?) -> Self {
        guard let filePath = path,
              let data = try? Data(contentsOf: filePath) else {
            fatalError("Could not load data from specified path: \(path?.absoluteString ?? "")")
        }
        return .success(data)
    }

}
