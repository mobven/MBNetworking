//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by Rasid Ramazanov on 17.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
@testable import MobKitCore
@testable import MBNetworking

class NetworkingTests: XCTestCase {
    
    override func setUp() {
        MobKit.isDeveloperModeOn = true
    }

    func testDataDownload() {
        let expectation = XCTestExpectation()
        var image: UIImage?
        Download.image(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            if case let .success(data) = result {
                image = UIImage(data: data)
            }
            expectation.fulfill()
        }
        XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(image)
    }
    
}

enum Download: Networkable {

    case image(url: URL)

    var request: URLRequest {
        switch self {
        case let .image(url):
            return getRequest(url: url, queryItems: [:])
        }
    }

}
