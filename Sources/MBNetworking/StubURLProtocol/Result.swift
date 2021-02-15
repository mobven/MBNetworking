//
//  Result.swift
//  Networking
//
//  Created by Rashid Ramazanov on 15.02.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

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

    /// Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.
    /// - Parameter path: Bundle URL path for the specifed resource. Can be received from `path(forResource:,ofType:`.
    /// - Returns: Returns StubURLProtocol.Result.success(Data) with data from specified path.
    static func getData(from path: URL?) -> Self {
        guard let filePath = path,
              let data = try? Data(contentsOf: filePath) else {
            fatalError("Could not load data from specified path: \(path?.absoluteString ?? "")")
        }
        return .success(data)
    }

}
