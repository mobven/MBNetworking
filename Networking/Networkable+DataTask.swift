//
//  Network.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

/// Networkable extension related to data tasks.
extension Networkable {
    
    /**
     Fetch data with specified parameters and return back with the completion.
     
     - parameter completion: Completion block to return response with the object confirming `Decodable`.
     */
    public func fetch<V: Decodable>(completion: @escaping (V?, Error?) -> ()) {
        fetch(request) { (data, error) in
            completion(data, error)
        }
    }
    
    private func fetch<V: Decodable>(_ urlRequest: URLRequest, completion: @escaping ((V?, Error?) -> Void)) {
        requestData(urlRequest) { (data, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(V.self, from: data)
                    completion(response, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    private func requestData(_ urlRequest: URLRequest, completion: @escaping ((Data?, Error?) -> Void)) {
        printRequest(urlRequest.url?.absoluteString ?? "", urlRequest.allHTTPHeaderFields, urlRequest.httpBody)
        let task = Session.shared().session
            .dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    completion(data, error)
                    self.printResponse(data)
                }
            })
        task.resume()
    }
    
}
