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
public final class StubURLProtocol {

    /// Result of the request, which is going to happen.
    public static var result: StubResult? {
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

    // TODO: Error case'lere bakalım 
    static func canResponse<V: Decodable>(
        _ type: V.Type, completion: @escaping ((Result<V, MBErrorKit.NetworkingError>) -> Void)
    ) -> Bool {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil else {
            return false
        }
        guard let result = StubURLProtocol.result else {
            return false
        }
        switch result {
        case let .success(data):
            do {
                // swiftlint:disable force_cast
                // If requested decodable type is Data, received data will be returned.
                if V.Type.self == Data.Type.self {
                    completion(.success(data as! V))
                    return true
                }
                let decodableData = try JSONDecoder().decode(V.self, from: data)
                completion(.success(decodableData))
            } catch {
                let error = MBErrorKit.NetworkingError
                    .decodingError((NSError(domain: "decoding error", code: -333)), nil, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
            }

        case let .failure(error):
            let error = MBErrorKit.NetworkingError.underlyingError(error, nil, nil)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            completion(.failure(error))
        case let .failureStatusCode(int):
            let error = MBErrorKit.NetworkingError.httpError(
                NSError(domain: "stub", code: int),
                HTTPURLResponse(
                    url: URL(string: "https://www.apple.com")!,
                    statusCode: int,
                    httpVersion: "",
                    headerFields: ["Content-Type": "application/json"]
                )!,
                nil
            )
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            completion(.failure(error))
        }
        // swiftlint:enable force_cast
        return true
    }
}
