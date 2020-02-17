//
//  Network+Logs.swift
//  Network
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

/// Networkable extension related to data tasks.
extension Networkable {
    
    func printRequest(_ url: String, _ headers: [String: String]?, _ data: Data?) {
        #if DEBUG
        print("\n\n\n\n")
        print("<-------- REQUEST -------->")
        print("Endpoint: \(url)")
        print("Headers: \(headers ?? [:])")
        printData(data)
        print("<-------- REQUEST -------->")
        #endif
    }
    
    func printResponse(_ data: Data?) {
        #if DEBUG
        print("\n\n\n\n")
        print("<-------- RESPONSE -------->")
        printData(data)
        print("<-------- RESPONSE -------->")
        #endif
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
