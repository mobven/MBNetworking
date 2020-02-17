//
//  Networkable+URLRequest.swift
//  Networking
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

/// `Networkable` extension related to `URLRequest`'s.
extension Networkable {
    
    /**
     Returns GET `URLRequest` with specified url and query item.
     
     - parameter url:`URL`.
     - parameter queryItems: Query items to be appended to the url, eg, pageSize: 10 will be appended to url as &pageSize=10.
     - returns: URLRequest with specified url and query item.
     */
    public func getRequest(url: URL, queryItems: [String: String] = [:],
                           headers: [String: String] = [:]) -> URLRequest {
        let url = url.adding(parameters: queryItems)
        return getRequest(with: url, httpMethod: .GET, headers: headers)
    }
    
    /**
     Returns POST `URLRequest` with specified url and encodable body object.
     
     - parameter url:`URL`.
     - parameter encodable: Any object confirming `Encodable` to be used in `URLRequest.httpBody`.
     - returns: `URLRequest` with specified url and encodable body object.
     */
    public func getRequest<T: Encodable>(url: URL, encodable data: T,
                                         headers: [String: String] = [:]) -> URLRequest {
        var request = getRequest(with: url, httpMethod: .POST, headers: headers)
        request.httpBody = try? JSONEncoder().encode(data)
        return request
    }
    
    /**
     Returns `URLRequest` with specified url and httpMehthod.
     
     - parameter url: `URL` of the request.
     - parameter httpMethod: HTTP method of the reuest, either GET or POST.
     - returns: `URLRequest` with specified url and httpMehthod.
     */
    private func getRequest(with url: URL, httpMethod: RequestType,
                            headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.allHTTPHeaderFields = getHeaders(headers)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return request
    }
    
    /// Returns default headers for used `URLRequest`s.
    private func getHeaders(_ headers: [String: String]) -> [String: String] {
        var heads = headers
        heads["Content-Type"] = NetworkContentType.json.rawValue
        return heads
    }
    
}

/// "Content-Type" values for network requests.
enum NetworkContentType: String {
    /// Content type used when expecting response  in JSON format.
    case json = "application/json"
}

/// Request types to be passed as `URLRequest.httpMethod`.
enum RequestType: String {
    
    /// HTTP GET request
    case GET = "GET"
    /// HTTP POST request
    case POST = "POST"
    
}
