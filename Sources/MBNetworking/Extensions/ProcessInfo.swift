//
//  ProcessInfo.swift
//  Networking
//
//  Created by Rashid Ramazanov on 17.02.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

extension ProcessInfo {

    /// Returns true if process is in testing.
    static var isUnderTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

}
