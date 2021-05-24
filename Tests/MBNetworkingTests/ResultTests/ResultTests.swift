//
//  ResultTests.swift
//  NetworkingTests
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
import MobKitCore
@testable import MBNetworking
@testable import MBErrorKit

struct DecodableWrong: Decodable {
    var resultCount: String?
}

struct DecodableTrue: Decodable {
    var resultCount: Int?
}

class ResultTests: XCTestCase {
    
    override func setUp() {
        MobKit.isDeveloperModeOn = true
    }

    func testDecodableWrong() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "results", withExtension: "json"))
        ResultTestAPI.fetch.fetch(DecodableWrong.self) { result in
            switch result {
            case .success:
                XCTFail("Result should fail.")
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "Decoding Error")
            }
        }
    }
    
    func testDecodableTrue() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "results", withExtension: "json"))
        ResultTestAPI.fetch.fetch(DecodableTrue.self) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.resultCount == 0)
            case .failure:
                XCTFail("Result should succeed.")
            }
        }
    }
    
    func testUnderlyingError() {
        StubURLProtocol.result = .failure(NSError(domain: "", code: -2, userInfo: nil))
        ResultTestAPI.underlyingError.fetch(DecodableTrue.self) { result in
            switch result {
            case .success:
                XCTFail("Result should fail.")
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "Underlying Error")
            }
        }
    }
    
    func testHTTPError() {
        StubURLProtocol.result = .failureStatusCode(500)
        ResultTestAPI.httpError.fetch(DecodableTrue.self) { result in
            switch result {
            case .success:
                XCTFail("Result should fail.")
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "HTTP Error")
            }
        }
    }

    func testNetworkError() {
        StubURLProtocol.result = .failure(NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil))
        ResultTestAPI.fetch.fetch(DecodableTrue.self) { result in
            switch result {
            case .success:
                XCTFail("Result should fail.")
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "Network Connection Error")
            }
        }
    }
    
}
