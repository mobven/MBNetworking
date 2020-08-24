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
    
    func printRequest(_ url: String, _ headers: [String: String]?, _ data: Data?) {
        if MobKit.isDeveloperModeOn {
            print("\n")
            print("<-------- MBNetworking Request -------->")
            print("Endpoint: \(url)")
            print("Headers: \(headers ?? [:])")
            printData(data)
            print("<-------- MBNetworking Request -------->")
            print("\n")
        }
    }
    
    func printResponse(_ data: Data?) {
        if MobKit.isDeveloperModeOn {
            print("\n")
            print("<-------- MBNetworking Response -------->")
            printData(data)
            print("<-------- MBNetworking Response -------->")
            print("\n")
        }
    }
    
    func printErrorLog(_ error: Error?) {
        if MobKit.isDeveloperModeOn {
            print("\n")
            print("<-------- MBNetworking Error -------->")
            print(error?.localizedDescription ?? "")
            print("<-------- MBNetworking Error -------->")
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
