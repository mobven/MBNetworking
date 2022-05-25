//
//  NetworkableLogTests.swift
//  MBNetworkingtests
//
//  Created by Rashid Ramazanov on 5/25/22.
//

import Foundation
import XCTest
@testable import MBErrorKit
@testable import MBNetworking
@testable import MobKitCore

class NetworkableLogTests: XCTestCase {
    override func setUp() {
        MobKit.isDeveloperModeOn = true
    }

    func testLogsWhenNil() {
        let expectation = expectation(description: "waiting")
        Download.data(
            url: URL(forceString: "https://walletdemo.firebaseio.com/5551232292.json")
        ).fetch(Data.self) { result in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        print()
    }
}
