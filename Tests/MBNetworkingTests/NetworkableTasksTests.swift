//
//  NetworkableTasksTests.swift
//  MBNetworking
//
//  Created by Rashid Ramazanov on 9/30/21.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation
import XCTest
@testable import MBErrorKit
@testable import MBNetworking
@testable import MobKitCore

class NetworkableTasksTests: XCTestCase {
    override func setUp() {
        MobKit.isDeveloperModeOn = true
        StubURLProtocol.delay = 0.3
        StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "imageDownload", withExtension: "jpg"))
    }

    override func tearDown() {
        Session.shared.tasksInProgress.removeAll()
    }

    func testSessionQueueHasDataTask_WhenFetchCalled() {
        makeACall()
        XCTAssertEqual(Session.shared.tasksInProgress.count, 1)
    }

    func testSessionQueueHasDataTaskWhenFetchCalledMultipleTimes() {
        for _ in 0 ... 3 {
            makeACall()
        }
        XCTAssertEqual(Session.shared.tasksInProgress.count, 4)
    }

    func testSessionQueueHasRemovedDataTask_WhenTaskIsFinished() {
        let expectation = XCTestExpectation(description: "waiting for image")
        makeACall(expectation)
        XCTAssertEqual(Session.shared.tasksInProgress.count, 1)
        wait(for: [expectation], timeout: 0.35)
        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
    }

    func testSessionQueueHasRemovedDataTask_WhenTaskIsFinishedForMultipleCalls() {
        let expectation = XCTestExpectation(description: "waiting for images")
        for index in 0 ... 3 {
            makeACall(index == 3 ? expectation : nil)
        }
        XCTAssertEqual(Session.shared.tasksInProgress.count, 4)
        wait(for: [expectation], timeout: 0.35)
        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
    }

    func testSessionQueueCancelsAllDataTasks() {
        let expectation = XCTestExpectation(description: "waiting for images")

        var errors: [Error] = []
        for index in 0 ... 3 {
            makeACall(index == 3 ? expectation : nil) { result in
                if case let .failure(error) = result,
                   case let .underlyingError(err, _, _) = error {
                    errors.append(err)
                }
            }
        }
        XCTAssertEqual(Session.shared.tasksInProgress.count, 4)

        NetworkableTasks.cancellAll()
        wait(for: [expectation], timeout: 0.5)

        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
        XCTAssertEqual(errors.count, 4)
        for error in errors {
            XCTAssertTrue((error as NSError).code == NSURLErrorCancelled)
        }
    }

    private func makeACall(
        _ expectation: XCTestExpectation? = nil, completion: ((Result<Data, NetworkingError>) -> Void)? = nil
    ) {
        Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            completion?(result)
            expectation?.fulfill()
        }
    }
}
