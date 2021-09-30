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
        NetworkableTasks.cancellAll()
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
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
    }

    func testSessionQueueHasRemovedDataTask_WhenTaskIsFinishedForMultipleCalls() {
        let expectation = XCTestExpectation(description: "waiting for images")
        for index in 0 ... 3 {
            makeACall(index == 3 ? expectation : nil)
        }
        XCTAssertEqual(Session.shared.tasksInProgress.count, 4)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
    }

    func testSessionQueueCancelsAllDataTasks() {
        let expectation = XCTestExpectation(description: "waiting for images")

        var errors: [NetworkingError] = []
        for index in 0 ... 3 {
            makeACall(index == 3 ? expectation : nil) { result in
                if case let .failure(error) = result {
                    print("appending error: \(error)")
                    errors.append(error)
                }
            }
        }
        XCTAssertEqual(Session.shared.tasksInProgress.count, 4)

        NetworkableTasks.cancellAll()
        wait(for: [expectation], timeout: 1)
        print("appended errors: \(errors)")
        XCTAssertTrue(Session.shared.tasksInProgress.isEmpty)
        XCTAssertEqual(errors.count, 4)
        for error in errors {
            if case NetworkingError.dataTaskCancelled = error {
                continue
            }
            XCTFail("Error is not in expected NetworkingError.dataTaskCancelled value.")
        }
    }

    private func makeACall(
        _ expectation: XCTestExpectation? = nil, completion: ((Result<Data, NetworkingError>) -> Void)? = nil
    ) {
        Download.data(
            url: URL(forceString: "https://miro.medium.com/max/1400/1*2AodTHXf8giVb4QoIBGSww.png")
        ).fetch(Data.self) { result in
            completion?(result)
            RunLoop.current.run(until: Date() + 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation?.fulfill()
            }
        }
    }
}
