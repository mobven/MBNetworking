//
//  Network.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation
import MBErrorKit

/// Networkable extension related to data tasks.
extension Networkable {
    
    /// Fetch data with specified parameters and return back with the completion.
    /// - Parameters:
    ///   - type: Type of the result.
    ///   - completion: Completion block to return response as `Result`
    public func fetch<V: Decodable>(_ type: V.Type, completion: @escaping ((Result<V, NetworkingError>) -> Void)) {
        self.fetch(request, completion: completion)
    }
    
    private func fetch<V: Decodable>(
        _ urlRequest: URLRequest,
        completion: @escaping ((Result<V, NetworkingError>) -> Void)
    ) {
        requestData(urlRequest) { (response, data, error) in
            
            if let error = error,
                self.isNetworkConnectionError((error as NSError).code) {
                
                let error = NetworkingError.networkConnectionError(error)
                ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
                
            } else if let error = error {
                
                let error = NetworkingError.underlyingError(error, response, data)
                ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
                
            } else if let httpResponse = response as? HTTPURLResponse,
                self.isSuccess(httpResponse.statusCode) {
                
                let error = NetworkingError.httpError(error, httpResponse, data)
                ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
                
            } else if let response = response, data == nil || data?.count == 0 {

                let error = NetworkingError.dataTaskError(response, data)
                ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
                
            } else if let data = data, data.count > 0 {
                
                do {
                    let decodableData = try JSONDecoder().decode(V.self, from: data)
                    completion(.success(decodableData))
                } catch let sError {
                    let error = NetworkingError.decodingError(sError, response, data)
                    ErrorKit.shared().delegate?.errorKitDidCatch(serializationError: error)
                    completion(.failure(error))
                }
                
            } else {
                
                let error = NetworkingError.unkownError(error, data)
                ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                completion(.failure(error))
                
            }
        }
    }
    
    func isNetworkConnectionError(_ errorCode: Int) -> Bool {
        return errorCode == NSURLErrorNetworkConnectionLost
            || errorCode == NSURLErrorNotConnectedToInternet
            || errorCode == NSURLErrorCannotConnectToHost
            || errorCode == 53
    }
    
    func isSuccess(_ errorCode: Int) -> Bool {
        return !(200...399).contains(errorCode)
    }
    
    private func requestData(_ urlRequest: URLRequest, completion: @escaping ((URLResponse?, Data?, Error?) -> Void)) {
        printRequest(urlRequest.url?.absoluteString ?? "", urlRequest.allHTTPHeaderFields, urlRequest.httpBody)
        let task = Session.shared.session
            .dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                self.printResponse(data)
                DispatchQueue.main.async {
                    completion(response, data, error)
                }
            })
        task.resume()
    }
    
}
