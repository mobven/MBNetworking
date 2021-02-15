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
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "imageDownload", withExtension: "jpg"))
        var image: UIImage?
        Download.image(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            if case let .success(data) = result {
                image = UIImage(data: data)
            }
        }
        XCTAssertNotNil(image)
    }

    func testURLProtocols() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
        var string: String?
        Download.image(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            if case let .success(data) = result {
                string = String(data: data, encoding: .utf8)
            }
        }
        XCTAssertEqual(string, "some\n")
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
