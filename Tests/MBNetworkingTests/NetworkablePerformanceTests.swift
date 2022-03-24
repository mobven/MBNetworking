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

    class NetworkablePerformanceTests: XCTestCase {
        var imageView: UIImageView = .init()

        override func setUp() {
            MobKit.isDeveloperModeOn = true
            NetworkableConfigs.default.set(configuration: URLSessionConfiguration.ephemeral)
        }

        func testWhenMultipleDownloadCommandCalled() {
            let expectation = XCTestExpectation(description: "wait for image")
            for i in 0 ..< 10000 {
                downloadImage(index: i)
            }
            XCTWaiter().wait(for: [expectation], timeout: 100)
            Timer.scheduledTimer(withTimeInterval: 100, repeats: false) { _ in
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
                case let .failure(error):
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

    enum API: Networkable {
        case getProfilePhoto

        var request: URLRequest {
            URLRequest(url: URL(forceString: "https://picsum.photos/200/300"))
        }
    }

    enum UIImageManager {
        static func convertImageToBase64String(img: UIImage) -> String {
            img.pngData()?.base64EncodedString() ?? ""
        }

        static func convertBase64StringToImage(data: Data) -> UIImage? {
            UIImage(data: data)
        }
    }

    enum FileIOManager {
        private static let localDirectory = "kutup_pp"

        @discardableResult static func writeFile(_ fileName: String, content: Data) -> Bool {
            guard let directory = getFileDirectory() else {
                return false
            }
            guard createDirectoryIfNeeded(directory) else {
                return false
            }
            let fileURL = directory.appendingPathComponent(fileName)
            do {
                try content.write(to: fileURL, options: .atomic)
                return true
            } catch {
                return false
            }
        }

        private static func createDirectoryIfNeeded(_ directory: URL) -> Bool {
            guard !FileManager.default.fileExists(atPath: directory.absoluteString) else {
                // Directory exists, no need to recreate it.
                return true
            }
            do {
                try FileManager.default.createDirectory(
                    at: directory, withIntermediateDirectories: true, attributes: nil
                )
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        }

        static func readFile(_ fileName: String) -> Data? {
            guard let directory = getFileDirectory() else {
                return nil
            }
            let fileURL = directory.appendingPathComponent(fileName)
            do {
                return try Data(contentsOf: fileURL)
            } catch {
                return nil
            }
        }

        private static func getFileDirectory() -> URL? {
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            return directory.appendingPathComponent(localDirectory, isDirectory: true)
        }
    }
#endif
