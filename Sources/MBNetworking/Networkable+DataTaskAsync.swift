//
//  Networkable+DataTaskAsync.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation
import MBErrorKit

/// Networkable extension related to data tasks.
///
@available(iOS 13.0.0, *) extension Networkable {
    /// Fetch data with specified parameters and return back with the completion.
    /// - Parameters:
    ///   - type: Type of the result.
    /// - Returns: Response as `Result`
    public func fetch<V: Decodable>(_ type: V.Type) async throws -> V {
        try await fetch(request)
    }

    private func fetch<V: Decodable>(_ urlRequest: URLRequest) async throws -> V {
        let (response, data, error) = await requestData(urlRequest)

        if let error,
           isNetworkConnectionError((error as NSError).code) {
            let error = MBErrorKit.NetworkingError.networkConnectionError(error)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            throw error

        } else if let error {
            let networkingError: NetworkingError = if (error as NSError).code == NSURLErrorCancelled {
                .dataTaskCancelled
            } else {
                MBErrorKit.NetworkingError.underlyingError(error, response, data)
            }
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: networkingError)
            printErrorLog(networkingError)
            throw networkingError

        } else if let httpResponse = response as? HTTPURLResponse,
                  isSuccess(httpResponse.statusCode) {
            let error = MBErrorKit.NetworkingError.httpError(error, httpResponse, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            throw error

        } else if let response, data == nil || data?.count == 0 {
            let error = MBErrorKit.NetworkingError.dataTaskError(response, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            throw error

        } else if let data, data.count > 0 {
            do {
                // If requested decodable type is Data, received data will be returned.
                if V.Type.self == Data.Type.self {
                    return data as! V
                }
                let decodableData = try JSONDecoder().decode(V.self, from: data)
                return decodableData
            } catch let sError {
                let error = MBErrorKit.NetworkingError.decodingError(sError, response, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(serializationError: error)
                self.printErrorLog(error)
                throw error
            }

        } else {
            let error = MBErrorKit.NetworkingError.unkownError(error, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            throw error
        }
    }
    
    private func requestData(_ urlRequest: URLRequest) async -> (URLResponse?, Data?, Error?) {
        let taskId = UUID().uuidString
        let task = Session.shared.session.dataTask(with: urlRequest)
        
        Session.shared.networkLogMonitoringDelegate?.logTaskCreated(task: task)
        task.resume()
        Session.shared.tasksInProgress.updateValue(task, forKey: taskId)
        
        defer {
            Session.shared.tasksInProgress.removeValue(forKey: taskId)
        }
        
        do {
            let (data, response) = try await Session.shared.session.data(for: urlRequest)
            
            if let task = Session.shared.tasksInProgress[taskId] {
                Session.shared.networkLogMonitoringDelegate?.logDataTask(dataTask: task, didReceive: data)
                Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didCompleteWithError: nil)
            }
            
            self.printResponse(data)
            return (response, data, nil)
        } catch {
            if let task = Session.shared.tasksInProgress[taskId] {
                Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didCompleteWithError: error)
            }
            return (nil, nil, error)
        }
    }
}
