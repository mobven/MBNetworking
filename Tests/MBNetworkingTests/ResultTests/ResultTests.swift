//
//  ResultTests.swift
//  NetworkingTests
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import MobKitCore
import XCTest
@testable import MBErrorKit
@testable import MBNetworking

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
        let expectation = expectation(description: "waiting")
        var apiResult: Result<DecodableWrong, NetworkingError>?
        ResultTestAPI.fetch.fetch(DecodableWrong.self) { result in
            apiResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        switch apiResult! {
        case .success:
            XCTFail("Result should fail.")
        case let .failure(error):
            XCTAssertTrue(error.errorTitle == "Decoding Error")
        }
    }

    func testDecodableTrue() {
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "results", withExtension: "json"))
        let expectation = expectation(description: "waiting")
        var apiResult: Result<DecodableTrue, NetworkingError>?
        ResultTestAPI.fetch.fetch(DecodableTrue.self) { result in
            apiResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        switch apiResult! {
        case let .success(response):
            XCTAssertTrue(response.resultCount == 0)
        case let .failure(error):
            XCTFail("expected success, got \(error.errorTitle)")
        }
    }

    func testUnderlyingError() {
        StubURLProtocol.result = .failure(NSError(domain: "", code: -2, userInfo: nil))
        let expectation = expectation(description: "waiting")
        var apiResult: Result<DecodableTrue, NetworkingError>?
        ResultTestAPI.underlyingError.fetch(DecodableTrue.self) { result in
            apiResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        switch apiResult! {
        case .success:
            XCTFail("Result should fail.")
        case let .failure(error):
            XCTAssertTrue(
                error.errorTitle == "Underlying Error", "expected underlying error, got \(error.errorTitle)"
            )
        }
    }

    func testHTTPError() {
        StubURLProtocol.result = .failureStatusCode(500)
        let expectation = expectation(description: "waiting")
        var apiResult: Result<DecodableTrue, NetworkingError>?
        ResultTestAPI.httpError.fetch(DecodableTrue.self) { result in
            apiResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        switch apiResult! {
        case .success:
            XCTFail("Result should fail.")
        case let .failure(error):
            XCTAssertTrue(
                error.errorTitle == "HTTP Error", "expected http error, got \(error.errorTitle)"
            )
        }
    }

    // TODO: stubURLProtocol de underlyingError veriyoruz.
    func testNetworkError() {
        StubURLProtocol.result = .failure(NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil))
        let expectation = expectation(description: "waiting")
        var apiResult: Result<DecodableTrue, NetworkingError>?
        ResultTestAPI.fetch.fetch(DecodableTrue.self) { result in
            apiResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        switch apiResult! {
        case .success:
            XCTFail("Result should fail.")
        case let .failure(error):
            XCTAssertTrue(
                error.errorTitle == "Network Connection Error", "expected failure, got \(error.errorTitle)"
            )
        }
    }
}
