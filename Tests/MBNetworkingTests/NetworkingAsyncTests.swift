//
//  NetworkingAsyncTests.swift
//  MBNetworking
//
//  Created by Umut Can ARDUÇ on 9.08.2024.
//  Copyright © 2021 Mobven. All rights reserved.
//

import XCTest
@testable import MBNetworking
@testable import MobKitCore

#if canImport(UIKit)
class NetworkingAsyncTests: XCTestCase {
    override func setUp() {
        MobKit.isDeveloperModeOn = true
        StubURLProtocol.delay = .zero
    }
    
    func testDataDownloadAsync() async throws {
        StubURLProtocol
            .result = .getData(from: Bundle.module.url(forResource: "imageDownload", withExtension: "jpg"))
        var image: UIImage?
        
        let result = try await Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self)
        
        if case let .success(actualData) = StubURLProtocol.result {
            XCTAssertEqual(result, actualData)
        }
        
        image = UIImage(data: result)
        
        XCTAssertNotNil(image)
    }
}
#endif
