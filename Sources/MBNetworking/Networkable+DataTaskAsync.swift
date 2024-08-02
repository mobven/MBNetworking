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
extension Networkable {
    /// Fetch data with specified parameters and return back with the completion.
    /// - Parameters:
    ///   - type: Type of the result.
    /// - Returns: Response as `Result`
    @available(iOS 13.0.0, *)
    public func fetch<V: Decodable>(_ type: V.Type) async -> Result<V, MBErrorKit.NetworkingError> {
        // StubURLProtocol enabled and adding a small delay.
        if StubURLProtocol.isEnabled, ProcessInfo.isUnderTest {
//            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            return await fetch(request)
        } else {
            return await fetch(request)
        }
    }

    @available(iOS 13.0.0, *) private func fetch<V: Decodable>(
        _ urlRequest: URLRequest
    ) async -> Result<V, MBErrorKit.NetworkingError> {
        let (response, data, error) = await requestData(urlRequest)

        if let error = error,
           isNetworkConnectionError((error as NSError).code) {
            let error = MBErrorKit.NetworkingError.networkConnectionError(error)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            return .failure(error)

        } else if let error = error {
            let networkingError: NetworkingError
            if (error as NSError).code == NSURLErrorCancelled {
                networkingError = .dataTaskCancelled
            } else {
                networkingError = MBErrorKit.NetworkingError.underlyingError(error, response, data)
            }
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: networkingError)
            printErrorLog(networkingError)
            return .failure(networkingError)

        } else if let httpResponse = response as? HTTPURLResponse,
                  isSuccess(httpResponse.statusCode) {
            let error = MBErrorKit.NetworkingError.httpError(error, httpResponse, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            return .failure(error)

        } else if let response = response, data == nil || data?.count == 0 {
            let error = MBErrorKit.NetworkingError.dataTaskError(response, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            return .failure(error)

        } else if let data = data, data.count > 0 {
            do {
                // If requested decodable type is Data, received data will be returned.
                if V.Type.self == Data.Type.self {
                    return .success(data as! V)
                }
                let decodableData = try JSONDecoder().decode(V.self, from: data)
                return .success(decodableData)
            } catch let sError {
                let error = MBErrorKit.NetworkingError.decodingError(sError, response, data)
                MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(serializationError: error)
                self.printErrorLog(error)
                return .failure(error)
            }

        } else {
            let error = MBErrorKit.NetworkingError.unkownError(error, data)
            MBErrorKit.ErrorKit.shared().delegate?.errorKitDidCatch(networkingError: error)
            printErrorLog(error)
            return .failure(error)
        }
    }

    @available(iOS 13.0.0, *)
    private func requestData(_ urlRequest: URLRequest) async -> (URLResponse?, Data?, Error?) {
        let taskId = UUID().uuidString
        do {
            let (data, response) = try await Session.shared.session.data(for: urlRequest)
            if let task = Session.shared.tasksInProgress[taskId] {
                Session.shared.networkLogMonitoringDelegate?.logDataTask(dataTask: task, didReceive: data)
                finalizeTask(withId: taskId, task: task)
            }
            printResponse(data)
            return (response, data, nil)
        } catch {
            if let task = Session.shared.tasksInProgress[taskId] {
                Session.shared.networkLogMonitoringDelegate?.logTask(task: task, didCompleteWithError: error)
                finalizeTask(withId: taskId, task: task)
            }
            return (nil, nil, error)
        }
    }

    func finalizeTask(withId taskId: String, task: URLSessionDataTask) {
        Session.shared.tasksInProgress.removeValue(forKey: taskId)

        Session.shared.networkLogMonitoringDelegate?.logTaskCreated(task: task)
        Session.shared.tasksInProgress.updateValue(task, forKey: taskId)
    }
}
