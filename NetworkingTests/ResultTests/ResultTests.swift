//
//  ResultTests.swift
//  NetworkingTests
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
@testable import Networking

struct DecodableWrong: Decodable {
    var resultCount: String?
}

struct DecodableTrue: Decodable {
    var resultCount: Int?
}

//var exceptedData = """
//{
//  "results" : [
//
//  ],
//  "resultCount" : 0
//}
//"""

class ResultTests: XCTestCase {

    func testDecodableWrong() {
        let expectation = XCTestExpectation(description: "Decodable Test")
        
        ResultTestAPI.fetch.fetchResult(type: DecodableWrong.self) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "Decoding Error")
            }
            
            expectation.fulfill()
        }

        let _ = XCTWaiter.wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecodableTrue() {
        let expectation = XCTestExpectation(description: "Decodable Test")
        
        ResultTestAPI.fetch.fetchResult(type: DecodableTrue.self) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.resultCount == 0)
            case .failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        let _ = XCTWaiter.wait(for: [expectation], timeout: 10.0)
    }
    
    func testUnderlyingError() {
        let expectation = XCTestExpectation(description: "Underlying Test")
        
        ResultTestAPI.underlyingError.fetchResult(type: DecodableTrue.self) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "Underlying Error")
            }
            
            expectation.fulfill()
        }
        
        let _ = XCTWaiter.wait(for: [expectation], timeout: 10.0)
    }
    
    func testHTTPError() {
        let expectation = XCTestExpectation(description: "HTTP Test")
        
        ResultTestAPI.httpError.fetchResult(type: DecodableTrue.self) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error.errorTitle == "HTTP Error")
            }
            
            expectation.fulfill()
        }
        
        let _ = XCTWaiter.wait(for: [expectation], timeout: 10.0)
    }

    func testNetworkError() {
        // Must be test on connection off
//
//        let expectation = XCTestExpectation(description: "Network Test")
        
//        ResultTestAPI.fetch.fetchResult(type: DecodableTrue.self) { result in
//            switch result {
//            case .success:
//                XCTFail()
//            case .failure(let error):
//                XCTAssertTrue(error.errorTitle == "Network Error")
//            }
//
//            expectation.fulfill()
//        }
//
//        let _ = XCTWaiter.wait(for: [expectation], timeout: 10.0)
    }
    
}
