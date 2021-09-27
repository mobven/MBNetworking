//
//  Network+Logs.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation
import MobKitCore

/// Networkable extension related to data tasks.
extension Networkable {
    
   func printResponse(_ data: Data?) {
        if MobKit.isDeveloperModeOn {
            print("\n")
            print("<-------- MBNetworking -------->")
            printRequestLog()
            print("Response Body:")
            printData(data)
            print("<-------- MBNetworking -------->")
            print("\n")
        }
    }
    
    func printErrorLog(_ error: Error?) {
        if MobKit.isDeveloperModeOn {
            print("\n")
            print("<-------- MBNetworking Error -------->")
            printRequestLog()
            print("Response Error: " + (error?.localizedDescription ?? ""))
            print("<-------- MBNetworking Error -------->")
            print("\n")
        }
    }
    
    private func printRequestLog() {
        print("Endpoint: \(request.url?.absoluteString ?? "")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody {
            print("Request Body:")
            printData(body)
            print("\n")
        }
    }
    
    private func printData(_ data: Data?) {
        if let data = data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let json = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                let string = String(data: json, encoding: .utf8) {
                print(string)
            } else if let string = String(data: data, encoding: .utf8) {
                print(string)
            }
        }
    }
    
}
