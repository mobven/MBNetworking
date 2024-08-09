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

// TODO: add NetworkingLegacyTests and separate NetworkingTests for async support.
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
                    if case let .success(actualData) = StubURLProtocol.result {
                        XCTAssertEqual(data, actualData)
                    }

                    image = UIImage(data: data)
                }
            }
            XCTAssertNotNil(image)
        }

        func testDataDownloadAsync() async throws {
            StubURLProtocol
                .result = .getData(from: Bundle.module.url(forResource: "imageDownload", withExtension: "jpg"))
            var image: UIImage?

            do {
                let result = try await Download.data(
                    url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
                ).fetch(Data.self)

                if case let .success(actualData) = StubURLProtocol.result {
                    XCTAssertEqual(result, actualData)
                }

                image = UIImage(data: result)
            } catch {
                print(error.localizedDescription)
                XCTFail()
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
