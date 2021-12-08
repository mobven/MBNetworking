//
//  NetworkableConfigsTests.swift
//  MBNetworking
//
//  Created by Rashid Ramazanov on 12/8/21.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation
import XCTest
@testable import MBErrorKit
@testable import MBNetworking
@testable import MobKitCore

class NetworkableConfigsTests: XCTestCase {
    func testURLSessionConfigurationDefaultValue() {
        XCTAssertEqual(Session.shared.configuration, URLSessionConfiguration.default)
        XCTAssertEqual(Session.shared.session.configuration, URLSessionConfiguration.default)
    }

    func testURLSessionConfigurationSetValue() {
        let configuration = URLSessionConfiguration.ephemeral
        NetworkableConfigs.default.set(configuration: configuration)
        XCTAssertEqual(Session.shared.configuration, configuration)
        XCTAssertEqual(Session.shared.session.configuration, configuration)
    }
}
