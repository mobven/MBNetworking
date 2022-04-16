//
//  SSLPinningTests.swift
//
//
//  Created by Rashid Ramazanov on 4/15/22.
//

import XCTest
@testable import MBErrorKit
@testable import MBNetworking
@testable import MobKitCore

class SSLPinningTests: XCTestCase {
    override func setUp() {
        MobKit.isDeveloperModeOn = true
        StubURLProtocol.result = nil
        StubURLProtocol.delay = .zero
    }

    func testSSLPinning() {
        setCertificate("macfit-ssl-cert")
        let expectation = expectation(description: "waiting")
        var pinningSucceeded = false
        let request = SendTokenRequest(phoneNumber: Array("5375373737"))
        API.Auth.sendToken(request: request).fetch(TokenResponse.self) { result in
            if case .success = result {
                pinningSucceeded = true
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(pinningSucceeded)
    }

    func testSSLPinningFailing() {
        setCertificate("denizbank-cert")
        let expectation = expectation(description: "waiting")
        var pinningFailed = false
        let request = SendTokenRequest(phoneNumber: Array("5375373737"))
        API.Auth.sendToken(request: request).fetch(TokenResponse.self) { result in
            if case let .failure(error) = result,
               case .dataTaskCancelled = error {
                pinningFailed = true
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(pinningFailed)
    }

    private func setCertificate(_ fileName: String) {
        if let path = Bundle.module.path(forResource: fileName, ofType: "der") {
            NetworkableConfigs.default.setCertificatePaths(path)
        } else {
            XCTFail("Could not find certificate with name \(fileName).der")
        }
    }

    enum API {
        enum Auth: Networkable {
            case sendToken(request: SendTokenRequest)

            public var request: URLRequest {
                switch self {
                case let .sendToken(request):
                    return getRequest(
                        url: URL(forceString: "https://api.macfit.com.tr/api/auth/sendToken"),
                        encodable: request,
                        headers: API.getHeaders()
                    )
                }
            }
        }

        static func getHeaders() -> [String: String] {
            var headers = ["Accept-Language": "tr"]
            headers["x-mobkit-deviceid"] = "123123"
            return headers
        }
    }

    public struct SendTokenRequest: Encodable {
        let userName: [Character]

        public init(phoneNumber: [Character]) {
            userName = phoneNumber
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(String(userName), forKey: .userName)
        }

        enum CodingKeys: String, CodingKey {
            case userName
        }
    }

    struct TokenResponse: Decodable {
        var statusCode: Int?
    }
}
