//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by Rasid Ramazanov on 17.02.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
@testable import MBNetworking
@testable import MobKitCore

#if canImport(UIKit)
    class NetworkingTests: XCTestCase {
        override func setUp() {
            MobKit.isDeveloperModeOn = true
            StubURLProtocol.delay = .zero
        }

        func testDataDownload() {
            StubURLProtocol
                .result = .getData(from: Bundle.module.url(forResource: "imageDownload", withExtension: "jpg"))
            var image: UIImage?
            Download.data(
                url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
            ).fetch(Data.self) { result in
                if case let .success(data) = result {
                    image = UIImage(data: data)
                }
            }
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
