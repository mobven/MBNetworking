//
//  NetworkablePerformanceTests.swift
//  MBNetworkingTests
//
//  Created by Rashid Ramazanov on 2/23/22.
//

#if canImport(UIKit)
import Foundation
import UIKit
import XCTest
@testable import MBErrorKit
@testable import MBNetworking
@testable import MobKitCore

class NetworkablePerformanceLegacyTests: XCTestCase {
    var imageView: UIImageView = .init()

    override func setUp() {
        MobKit.isDeveloperModeOn = true
        NetworkableConfigs.default.set(configuration: URLSessionConfiguration.ephemeral)
    }

    func testWhenMultipleDownloadCommandCalled() {
        let expectation = XCTestExpectation(description: "wait for image")
        for i in 0 ..< 1000 {
            downloadImage(index: i)
        }
        XCTWaiter().wait(for: [expectation], timeout: 10)
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            expectation.fulfill()
        }
    }

    private func downloadImage(index: Int) {
        imageView.downloadImageFrom(index: index)
    }
}

extension UIImageView {
    func downloadImageFrom(index: Int) {
        if let savedImage = FileIOManager.readFile("\(index)"),
           let image = UIImage(data: savedImage) {
            self.image = image
        }
        getProfilePhoto { result in
            switch result {
            case let .success(data):
                self.image = UIImage(named: "ky_avatar")
                let image = UIImage(data: data)
                self.image = image
                FileIOManager.writeFile("\(index)", content: data)
            case .failure(_):
                return
            }
        }
    }

    private func getProfilePhoto(
        completion: @escaping (Result<Data, NetworkingError>) -> Void
    ) {
        API.getProfilePhoto.fetch(Data.self, completion: completion)
    }
}
#endif
