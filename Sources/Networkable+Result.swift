//
//  Networkable+Result.swift
//  Networking
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

extension Networkable {
    
    
    /// Fetch data with specified parameters and return back with the completion.
    /// - Parameters:
    ///   - type: `Decodable`  type which fetched `Data` will cenvert if possible
    ///   - completion: Completion block to return response with the object confirming `Result<Decodable, NetworkingError>`
    public func fetchResult<V: Decodable>(type: V.Type, completion: @escaping ((Result<V, NetworkingError>) -> Void)) {
        self.fetch(request, completion: completion)
    }
    
    private func fetch<V: Decodable>(_ urlRequest: URLRequest, completion: @escaping ((Result<V, NetworkingError>) -> Void)) {
        requestData(urlRequest) { (response, data, error) in
            
            if let error = error,
                self.isNetworkConnectionError((error as NSError).code) {
                
                completion(.failure(.networkConnectionError(error)))
                
            } else if let error = error {
                
                completion(.failure(.underlyingError(error, response)))
                
            } else if let httpResponse = response as? HTTPURLResponse,
                self.isSuccess(httpResponse.statusCode) {
                
                completion(.failure(.httpError(error, httpResponse)))
                
            } else if let response = response, data == nil || data?.count == 0 {
                
                completion(.failure(.dataTaskError(response, data)))
                
            }  else if let data = data, data.count > 0 {
                
                do {
                    let decodableData = try JSONDecoder().decode(V.self, from: data)
                    completion(.success(decodableData))
                } catch {
                    completion(.failure(.decodingError(error, response)))
                }
                
            } else {
                completion(.failure(.unkownError(error)))
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
                DispatchQueue.main.async {
                    completion(response, data, error)
                    self.printResponse(data)
                }
            })
        task.resume()
    }
    
    
}
