//
//  File.swift
//  
//
//  Created by Rashid Ramazanov on 16.02.2021.
//

import Foundation
import XCTest
@testable import MobKitCore
@testable import MBNetworking

class StubURLProtocolTests: XCTestCase {

    override func setUp() {
        MobKit.isDeveloperModeOn = true

    }

    func test_When_StubProtocolSet() {
        // Enabling StubURLProtocol
        StubURLProtocol.result = .failureStatusCode(401)
        XCTAssertTrue(
            Session.shared.session.configuration.protocolClasses?.first is StubURLProtocol.Type
        )
    }

    func test_StubProtocol_GetDataFromUrl() {
        let result = StubURLProtocol.Result.getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
        XCTAssertNotNil(result)
    }

    func test_StubProtocol_GetDataFromPath() {
        let result = StubURLProtocol.Result.getData(from: Bundle.module.path(forResource: "some", ofType: "txt"))
        XCTAssertNotNil(result)
    }

    func test_When_StubProtocolReadsData() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
        var string: String?
        Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            if case let .success(data) = result {
                string = String(data: data, encoding: .utf8)
            }
        }
        XCTAssertEqual(string, "some\n")
    }

    func test_When_StubProtocolCleared() {
        StubURLProtocol.result = nil
        var image: UIImage?
        Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            if case let .success(data) = result {
                image = UIImage(data: data)
            }
        }
        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)
        // The real image in the link is 1400x637 size.
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size.width, 1400)
    }

}
