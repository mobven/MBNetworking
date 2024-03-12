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
    public func fetch<V: Decodable>(
        _ type: V.Type,
        completion: @escaping ((Result<V, MBErrorKit.NetworkingError>) -> Void)
    ) {
        // StubURLProtocol enabled and adding a small delay.
        if StubURLProtocol.isEnabled, ProcessInfo.isUnderTest {
            fetch(request, completion: completion)
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        } else {
            fetch(request, completion: completion)
        }
    }

    private func fetch<V: Decodable>(
        _ urlRequest: URLRequest,
        completion: @escaping ((Result<V, MBErrorKit.NetworkingError>) -> Void)
    ) {
        requestData(urlRequest) { response, data, error in

            if let error = error,
               self.isNetworkConnectionError((error as NSError).code) {
                let error = MBErrorKit.NetworkingError.networkConnectionError(error)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                self.printErrorLog(error)
                completion(.failure(error))

            } else if let error = error {
                let networkingError: NetworkingError
                if (error as NSError).code == NSURLErrorCancelled {
                    networkingError = .dataTaskCancelled
                } else {
                    networkingError = MBErrorKit.NetworkingError.underlyingError(error, response, data)
                }
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: networkingError)
                self.printErrorLog(networkingError)
                completion(.failure(networkingError))

            } else if let httpResponse = response as? HTTPURLResponse,
                      self.isSuccess(httpResponse.statusCode) {
                let error = MBErrorKit.NetworkingError.httpError(error, httpResponse, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                self.printErrorLog(error)
                completion(.failure(error))

            } else if let response = response, data == nil || data?.count == 0 {
                let error = MBErrorKit.NetworkingError.dataTaskError(response, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                self.printErrorLog(error)
                completion(.failure(error))

            } else if let data = data, data.count > 0 {
                do {
                    // If requested decodable type is Data, received data will be returned.
                    if V.Type.self == Data.Type.self {
                        completion(.success(data as! V))
                        return
                    }
                    let decodableData = try JSONDecoder().decode(V.self, from: data)
                    completion(.success(decodableData))
                } catch let sError {
                    let error = MBErrorKit.NetworkingError.decodingError(sError, response, data)
                    MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(serializationError: error)
                    self.printErrorLog(error)
                    completion(.failure(error))
                }

            } else {
                let error = MBErrorKit.NetworkingError.unkownError(error, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
                self.printErrorLog(error)
                completion(.failure(error))
            }
        }
    }

    func isNetworkConnectionError(_ errorCode: Int) -> Bool {
        errorCode == NSURLErrorNetworkConnectionLost
            || errorCode == NSURLErrorNotConnectedToInternet
            || errorCode == NSURLErrorCannotConnectToHost
            || errorCode == 53
    }

    func isSuccess(_ errorCode: Int) -> Bool {
        !(200 ... 399).contains(errorCode)
    }

    private func requestData(_ urlRequest: URLRequest, completion: @escaping ((URLResponse?, Data?, Error?) -> Void)) {
        let taskId = UUID().uuidString
        let task = Session.shared.session
            .dataTask(with: urlRequest, completionHandler: { data, response, error in
                if let task = Session.shared.tasksInProgress[taskId] {
                    if let error {
                        Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didCompleteWithError: error)
                    } else if let data {
                        Session.shared.networkLogMonitoringDelegate?.logDataTask(dataTask: task, didReceive: data)
                    }
                }
                
                Session.shared.tasksInProgress.removeValue(forKey: taskId)
                
                self.printResponse(data)
                DispatchQueue.main.async {
                    completion(response, data, error)
                }
            })
        Session.shared.networkLogMonitoringDelegate?.logTaskCreated(task: task)
        task.resume()
        Session.shared.tasksInProgress.updateValue(task, forKey: taskId)
    }
}
