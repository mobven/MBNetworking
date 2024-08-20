//
//  Networkable.swift
//  Networking
//
//  Created by Rasid Ramazanov on 25.11.2019.
//  Copyright © 2019 LeanScale. All rights reserved.
//

import Foundation

public protocol Networkable {
    /// `URLRequest` of the request.
    var request: URLRequest { get }
}
