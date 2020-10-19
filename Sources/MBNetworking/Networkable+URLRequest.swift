//
//  Networkable+URLRequest.swift
//  Networking
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation
import MBErrorKit

/// `Networkable` extension related to `URLRequest`'s.
extension Networkable {
    
    /**
     Returns GET `URLRequest` with specified url and query item.
     
     - parameter url:         `URL`.
     - parameter queryItems:  Query items to be appended to the url,
     eg, pageSize: 10 will be appended to url as &pageSize=10.
     - parameter headers:     HTTP headers.
     - returns: `URLRequest` with specified url and query item.
     */
    public func getRequest(url: URL, queryItems: [String: String] = [:],
                           headers: [String: String] = [:]) -> URLRequest {
        let url = url.adding(parameters: queryItems)
        var request = getRequest(with: url,
                                 httpMethod: .GET,
                                 headers: headers,
                                 contentType: .json)
        request.timeoutInterval = Session.shared.timeout.request
        return request
    }
    
    /**
     Returns POST `URLRequest` with specified url and encodable body object.
     
     - parameter url:         `URL`.
     - parameter encodable:   Any object confirming `Encodable` to be used in `URLRequest.httpBody`.
     - parameter headers:     HTTP headers.
     - returns: `URLRequest` with specified url and encodable body object.
     */
    public func getRequest<T: Encodable>(url: URL,
                                         encodable data: T,
                                         headers: [String: String] = [:]) -> URLRequest {
        var request = getRequest(with: url, httpMethod: .POST,
                                 headers: headers, contentType: .json)
        do {
            request.httpBody = try JSONEncoder().encode(data)
        } catch {
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(
                serializationError: MBErrorKit.NetworkingError.encodingError(error, request)
            )
            printErrorLog(error)
        }
        request.timeoutInterval = Session.shared.timeout.request
        return request
    }
    
    /**
     Returns POST `URLRequest` with specified url and encodable body object.
     
     - parameter url:         `URL`.
     - parameter formItems:   HashMap to be used in `URLRequest.httpBody`.
     - parameter headers:     HTTP headers.
     - parameter contentType: Content-Type of the request.
     - returns: `URLRequest` with specified url and encodable body object.
     */
    public func getRequest(url: URL,
                           formItems: [String: String] = [:],
                           headers: [String: String] = [:]) -> URLRequest {
        let formData = formItems.map({
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .nwURLQueryAllowed) ?? "")"
        }).joined(separator: "&")
        var request = getRequest(with: url, httpMethod: .POST,
                                 headers: headers, contentType: .urlencoded)
        request.httpBody = formData.data(using: .utf8)
        request.timeoutInterval = Session.shared.timeout.request
        return request
    }
    
    /**
     Returns `URLRequest` with specified url and httpMehthod.
     
     - parameter url:         `URL` of the request.
     - parameter httpMethod:  HTTP method of the reuest, either GET or POST.
     - parameter headers:     HTTP headers.
     - parameter contentType: Content-Type of the request.
     - returns: `URLRequest` with specified url and httpMehthod.
     */
    private func getRequest(with url: URL, httpMethod: RequestType,
                            headers: [String: String],
                            contentType: NetworkContentType) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.allHTTPHeaderFields = getHeaders(headers, contentType: contentType)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return request
    }
    
    /// Returns default headers for used `URLRequest`s.
    private func getHeaders(_ headers: [String: String],
                            contentType: NetworkContentType) -> [String: String] {
        var heads = headers
        heads["Content-Type"] = contentType.rawValue
        return heads
    }
    
}

/// "Content-Type" values for network requests.
public enum NetworkContentType: String {
    /// Content type used when expecting response  in JSON format.
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
}

/// Request types to be passed as `URLRequest.httpMethod`.
enum RequestType: String {
    
    /// HTTP GET request
    case GET
    /// HTTP POST request
    case POST
    
}
