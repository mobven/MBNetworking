//
//  Result.swift
//  Networking
//
//  Created by Rashid Ramazanov on 15.02.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

extension StubURLProtocol {
    public enum StubResult {
        /// Successfull result with specified data
        /// You can use `StubURLProtocol.Result.getData()` to read mock data from bundle, easily and inline.
        case success(Data)
        /// Failure with the specified Error.
        /// The  actual result of `Networkable.fetch` will be `NetworkingError.underlyingError`.
        case failure(Error)
        /// Failure with the specified status code.
        /// The  actual result will of `Networkable.fetch` will be `NetworkingError.httpError`.
        case failureStatusCode(Int)
    }
}

public extension StubURLProtocol.StubResult {
    /// Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.
    /// - Parameter url: Bundle URL for the specifed resource. Can be received from `url(forResource:,ofType:)`.
    /// - Returns: Returns `StubURLProtocol.Result.success(Data)` with data from specified file url.
    static func getData(from url: URL?) -> Self {
        guard let fileUrl = url,
              let data = try? Data(contentsOf: fileUrl) else {
            fatalError("Could not load data from specified path: \(url?.absoluteString ?? "")")
        }
        return .success(data)
    }

    /// Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.
    /// - Parameter path: Bundle path for the specifed resource. Can be received from `path(forResource:,ofType:)`.
    /// - Returns: `Returns StubURLProtocol.Result.success(Data)` with data from specified file path.
    static func getData(from path: String?) -> Self {
        guard let filePath = path,
              let url = URL(string: "file://\(filePath)"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Could not load data from specified path: \(path ?? "")")
        }
        return .success(data)
    }
}
