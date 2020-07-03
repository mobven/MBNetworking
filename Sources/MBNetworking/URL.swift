//
//  URL.swift
//  Networking
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

extension URL {
    
    /// Initializes URL with string. Same as URL(string:), but returns URL (not optional.)
    /// In case of failure in initializing, fatal error will be thrown.
    public init(forceString string: String) {
        guard let url = URL(string: string) else { fatalError("Could not init URL '\(string)'") }
        self = url
    }
    
    /// Returns URL by settings URL.queryItems to specified parameters.
    public func adding(parameters: [String: String]) -> URL {
        guard parameters.count > 0 else { return self }
        var queryItems: [URLQueryItem] = []
        for parameter in parameters {
            queryItems.append(URLQueryItem(name: parameter.key, value: parameter.value))
        }
        return adding(queryItems: queryItems)
    }
    
    /// Returns URL by settings URL.queryItems to specified queryItems.
    private func adding(queryItems: [URLQueryItem]) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else {
            fatalError("Could not create URLComponents using URL: '\(absoluteURL)'")
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            fatalError("Could not create URL")
        }
        return url
    }
    
}
