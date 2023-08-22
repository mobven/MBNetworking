//
//  StubURLProtocolTests.swift
//
//  MBNetworkingTests
//  Created by Rashid Ramazanov on 16.02.2021.
//

import Foundation
import XCTest
@testable import MBNetworking
@testable import MobKitCore

class StubURLProtocolTests: XCTestCase {
    override func setUp() {
        MobKit.isDeveloperModeOn = true
        StubURLProtocol.result = nil
        Session.shared.certificatePaths = []
    }

    func test_When_StubProtocolSet() {
        // Enabling StubURLProtocol
        StubURLProtocol.result = .failureStatusCode(401)
        XCTAssertTrue(
            Session.shared.session.configuration.protocolClasses?.first is StubURLProtocol.Type
        )
    }

    func test_StubProtocol_GetDataFromUrl() {
        let result = StubURLProtocol.StubResult.getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
        XCTAssertNotNil(result)
    }

    func test_StubProtocol_GetDataFromPath() {
        let result = StubURLProtocol.StubResult.getData(from: Bundle.module.path(forResource: "some", ofType: "txt"))
        XCTAssertNotNil(result)
    }

    // TODO: Bu test kalıcakmı?
//    func test_When_StubProtocolHasDelay() {
//        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
//        StubURLProtocol.delay = 0.3
//        var string: String?
//        let expectation = expectation(description: "wait for delay")
//        Download.data(
//            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
//        ).fetch(Data.self) { result in
//            if case let .success(data) = result {
//                string = String(data: data, encoding: .utf8)
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: StubURLProtocol.delay)
//        XCTAssertEqual(string, "some\n")
//    }

    func test_When_StubProtocolFetchesJSON() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "results", withExtension: "json"))
        var response: DecodableTrue?
        Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(DecodableTrue.self) { result in
            if case let .success(resp) = result {
                response = resp
            }
        }
        // The image in the link is 200x150 size.
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.resultCount, 0)
    }

    #if canImport(UIKit)
        func test_When_StubProtocolDownloadsImage() {
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
            // The image in the link is 200x150 size.
            XCTAssertNotNil(image)
            XCTAssertEqual(image?.size.width, 200)
        }

        func test_When_StubProtocolCleared() {
            StubURLProtocol.result = nil
            var image: UIImage?
            let expectation = expectation(description: "waiting")
            Download.data(
                url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
            ).fetch(Data.self) { result in
                if case let .success(data) = result {
                    image = UIImage(data: data)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
            // The real image in the link is 1400x637 size.
            XCTAssertNotNil(image)
            XCTAssertEqual(image?.size.width, 1400)
        }
    #endif
}
