//
//  Networkable+Logs.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation
import MBErrorKit
import MobKitCore
import OSLog

@available(iOS 14.0, *) let logger = Logger(subsystem: "MBNetworking", category: "Network Logs")

/// Networkable extension related to data tasks.
extension Networkable {
    func printResponse(_ data: Data?) {
        if MobKit.isDeveloperModeOn {
            printLog(getRequestLog() + "\n" + getStringFrom(data))
        }
    }

    func printErrorLog(_ error: Error?) {
        if MobKit.isDeveloperModeOn {
            printLog(getRequestLog() + "\n" + (error?.localizedDescription ?? ""), level: .error)
        }
    }

    func printErrorLog(_ error: NetworkingError?) {
        if MobKit.isDeveloperModeOn {
            printLog(getRequestLog() + "\n" + (error?.errorDescription ?? ""), level: .error)
        }
    }

    private func getRequestLog() -> String {
        var log = "Endpoint: \(request.url?.absoluteString ?? "")"
        log.append("\n")
        log.append("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody {
            log.append("\n")
            log.append("Request Body:")
            log.append(getStringFrom(body))
        }
        return log
    }

    func printLog(_ log: String, level: OSLogType = .info) {
        if #available(iOS 14.0, *) {
            logger.log(level: level, "\(log)")
        } else {
            print(log)
        }
    }

    private func getStringFrom(_ data: Data?) -> String {
        if let data = data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
               !(jsonObject is NSNull),
               let json = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let string = String(data: json, encoding: .utf8) {
                return string
            } else if let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        return ""
    }
}
