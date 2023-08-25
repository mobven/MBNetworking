# Unit Testing
URLProtocol for simplifying unit tests by acting man-in-the-middle on for the session. It's configured to work only with test targets. It won't work if there's no test process in progress.
The UnitTestStub class is created, and within this class, the canResponse function is defined. In its closure, it returns a result or error of the type we provide. This simulates making an API request, reads the data from the provided JSON file, and returns it as if an actual API call had been made.
```swift
final class UnitTestStubs {
    /// Result of the request, which is going to happen.
    static var result: StubResult?

    static func canResponse<V: Decodable>(
        _ type: V.Type, completion: @escaping ((Result<V, Error>) -> Void)
    ) -> Bool {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil else {
            return false
        }
        guard let result = MarketUnitTestStubs.result else {
            return false
        }
        switch result {
        case let .success(data):
            do {
                // swiftlint:disable force_cast
                guard !(V.self is MarketEmptyCodable.Type) else {
                    completion(.success(MarketEmptyCodable() as! V))
                    return true
                }
                let response = try JSONDecoder().decode(V.self, from: data)
                completion(.success(response))
                // swiftlint:enable force_cast
            } catch {
                completion(
                    .failure(NSError(domain: "decoding error", code: -333))
                )
            }
        case let .failure(error):
            completion(.failure(error))
        case let .failureStatusCode(int):
            completion(.failure(NSError(domain: "stub", code: int)))
        }
        return true
    }
}
```

We write API responses as an extension to the UnitTestStub class.
```swift
extension MarketUnitTestStubs {
    enum StubResult {
        /// Successfull result with specified data
        /// You can use `StubURLProtocol.Result.getData()` to read mock data from bundle, easily and inline.
        case success(Data)
        /// Failure with the specified Error.
        /// The  actual result of `Networkable.fetch` will be `NetworkingError.underlyingError`.
        case failure(Error)
        /// Failure with the specified status code.
        /// The  actual result will of `Networkable.fetch` will be `NetworkingError.httpError`.
        case failureStatusCode(Int)
    }
}
```
Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.

```swift
extension MarketUnitTestStubs.StubResult {
    /// Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.
    /// - Parameter url: Bundle URL for the specifed resource. Can be received from `url(forResource:,ofType:)`.
    /// - Returns: Returns `StubURLProtocol.Result.success(Data)` with data from specified file url.
    static func getData(from url: URL?) -> Self {
        guard let fileUrl = url,
              let data = try? Data(contentsOf: fileUrl) else {
            fatalError("Could not load data from specified path: \(url?.absoluteString ?? "")")
        }
        return .success(data)
    }

    /// Prepares `StubURLProtocol.Result.success(Data)` from specified Bundle path.
    /// - Parameter path: Bundle path for the specifed resource. Can be received from `path(forResource:,ofType:)`.
    /// - Returns: `Returns StubURLProtocol.Result.success(Data)` with data from specified file path.
    static func getData(from path: String?) -> Self {
        guard let filePath = path,
              let url = URL(string: "file://\(filePath)"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Could not load data from specified path: \(path ?? "")")
        }
        return .success(data)
    }
}
```

In the place where you make generic API requests, call the UnitTestStub.canResponse function before calling the fetch function. 
This way, during testing, the system can read data from the JSON file you provided and simulate receiving a response from the API without actually making the API request.

```swift
public protocol AppNetworkable: Networkable {}

public extension AppNetworkable {
    func fetchResponse<V: Decodable>(
        _ type: V.Type, showLoader: Bool = false, completion: @escaping ((Result<V, Error>) -> Void)
    ) {
        guard !UnitTestStubs.canResponse(type, completion: completion) else { return }
        showLoader ? Loader.shared.show() : ()
        fetch(AppResponse<V>.self) { result in
            showLoader ? Loader.shared.hide() : ()
            fetchResponseResult(result, completion: completion)
        }
    }
}
```
### Example
Api request
```swift
public extension API {
    enum Address: AppNetworkable {
        case getCities(isTani: Bool = false)

        public var request: URLRequest {
            switch self {
            case let .getCities(isTani):
                return getRequest(
                    url: API.getURL(with: "v1/location/\(isTani ? "taniCities" : "cities")"),
                    queryItems: [:],
                    headers: API.getHeaders(),
                    httpMethod: .GET
                )
            }
        }
    }
}
```
Api Response model

```swift
public struct GetActivitiesResponse: Decodable {
    public let activities: [ActivityModel]?

    public struct ActivityModel: Codable {
        public let activityGUID: String?
        public let webID: Int?
        public let companyName: String?
        public let categoryName: String?
        public let title: String?
        public let description: String?
        public let totalQuota: Int?
        public let joinedCount: Int?
        public let joinStartDate: String?
        public let joinEndDate: String?
        public let image: String?
        public let imageMobile: String?
        public let spotImage: String?
        public let spotTitle: String?
        public let spotDescription: String?
        public let joined: Bool?
    }
}
```
Worker function

```swift
    func getActivities(_ completion: @escaping (Result<GetActivitiesResponse, Error>) -> Void) {
        API.Activity.getActivities.fetchResponse(GetActivitiesResponse.self, completion: completion)
    }
```

To enable it to read and return from a JSON file, you'll need a JSON file for testing purposes. This file will contain the mock response data that your UnitTestStub class will use to simulate API responses. Here's how you can set it up:
Create a JSON file named "MockResponse.json" (or any name you prefer) in your project's directory.
Populate this JSON file with the mock response data you want to use during testing. For example:
```swift
{
  "status": 200,
  "data": {
    "activities": [
      {
        "activityGUID": "fa2f7924-7d03-462b-82d3-6710db23e28b",
        "webID": 1,
        "companyName": "Arçelik",
        "categoryName": "Eğlence",
        "title": "Title Test !'^+%&/()=?_",
        "description": "Description test&nbsp;!&#39;^+%&amp;/()=?_",
        "totalQuota": 250,
        "joinedCount": 3,
        "joinStartDate": "2023-05-16T10:28:21.000Z",
        "joinEndDate": "2024-05-16T10:28:21.000Z",
        "image": "https://preprod.kocailem.com//KocAilem-Preprod/media/Campaigns/TEST1_5.png?ext=.png",
        "imageMobile": "https://preprod.kocailem.com//KocAilem-Preprod/media/Campaigns/TEST1_6.png?ext=.png",
        "spotImage": "https://preprod.kocailem.com//KocAilem-Preprod/media/Campaigns/TEST1_4.png?ext=.png",
        "spotTitle": "Spot Title !'^+%&/()=?_",
        "spotDescription": "Spot Description&nbsp;!&#39;^+%&amp;/()=?_",
        "joined": false
      }
    ]
  }
}
```
Certainly, you can set up the UnitTestStubs class to return a predefined result without making an actual API call. This is useful for testing different scenarios without hitting the actual network.
Here's how you can do it:

```swift
func testGetActivities() {
    UnitTestStubs.result = .getData(
        from: Bundle(for: Self.self)
            .path(forResource: "ListAddress", ofType: "json")
    )
    worker.getActivities { [weak self] result in
        guard let self else { return }
        if case let .success(response) = result {
             XCTAssert(response.activities != nil)
        }
    }
}
 ```
 You can use the same approach to test error cases using your UnitTestStubs. 
 Here's how you can set up the stub to return an error result for testing:

 ```swift
func testFetchActivityWithError() {
    UnitTestStubs.result = .failureStatusCode(501)
    // When
    interactor.fetchActivity()
    // Then
    XCTAssertTrue(presenterSpy.presentErrorCalled)
}
 ```