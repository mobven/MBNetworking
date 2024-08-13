//
//  NetworkingLegacyTests.swift
//  NetworkingTests
//
//  Created by Rasid Ramazanov on 17.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
@testable import MBNetworking
@testable import MobKitCore

#if canImport(UIKit)
    class NetworkingLegacyTests: XCTestCase {
        override func setUp() {
            MobKit.isDeveloperModeOn = true
            StubURLProtocol.delay = .zero
        }

        func testDataDownload() {
            let expectation = expectation(description: "Data download should succeed and produce a valid image")
            StubURLProtocol.result = .getData(from: Bundle.module.url(
                forResource: "imageDownload",
                withExtension: "jpg"
            ))
            var image: UIImage?

            Download.data(
                url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
            ).fetch(Data.self) { result in
                if case let .success(data) = result {
                    if case let .success(actualData) = StubURLProtocol.result {
                        XCTAssertEqual(data, actualData)
                    }

                    image = UIImage(data: data)
                }
                expectation.fulfill()
            }
            waitForExpectations(timeout: 5, handler: nil)

            XCTAssertNotNil(image)
        }
    }
#endif

enum Download: Networkable {
    case data(url: URL)

    var request: URLRequest {
        switch self {
        case let .data(url):
            return getRequest(url: url, queryItems: [:])
        }
    }
}
