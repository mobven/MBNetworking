# Networking

Networking is a design-pattern framework based on Apple's `URLSession`. It's evolved from the idea of replacing `Alamofire` (in some projects also `Moya`) with native `URLSession` functions.

## Requirements

- iOS 10.0+
- Xcode 12+
- Swift 5.3+

## Installation

### Swift Package Manager
Framework is supported only via Swift Package Manager and is not planned to be distributed otherwise, unless there is a specific requirement. As Swift Package Manager is the first official distribution tool managed by Apple for Swift, it's stable currently and there is an active development on it which promises it will be used for a while.

Project can be installed using SPM with its github URL.
```bash
https://github.com/mobven/Networking
```

## Usage
Networkable functionalities can be achieved creating enums which conform to `Networkable` protocol and overriding its `request` parameter. Later, when `fetch` is called,  `Networkable` uses this `request` to proceed the request.  

### Creating Networkables
```swift
import MBNetworking
enum API {
    enum Login: Networkable {
        /// Login with username and password with GET request.
        case loginGet(username: String, password: String)
        /// Login with username and password with POST request.
        case loginPost(request: LoginRequest)
        
        var request: URLRequest {
            switch self {
            case let .loginGet(username, password):
                return getRequest(url: API.getURL(endpoint: "LoginPOST"),
                                  queryItems: ["username": username, "password": password])
            case let .loginPost(request):
                return getRequest(url: API.getURL(endpoint: "LoginGET"),
                                  encodable: request)
            }
        }
    }
    
    private static func getURL(endpoint: String) -> URL {
        let baseEndpoint = "https://example.com/api/"
        return URL(forceString: "\(baseEndpoint)\(endpoint)")
    }
}
struct LoginRequest: Encodable {
    var username: String
    var password: String
}
```

### Fetching data from Networkables 
```swift
API.Login.loginGet(username: "admin", password: "admin").fetch(LoginResponse.self) { result in
    switch result {
    case let .success(response):
        print("Succeeded with \(response)")
    case let .failure(error):
        print("Failed with \(error)")
    }
}
API.Login.loginPost(request: LoginRequest(username: "admin", password: "admin")).fetch(LoginResponse.self) { result in
    switch result {
    case let .success(response):
        print("Succeeded with \(response)")
    case let .failure(error):
        print("Failed with \(error)")
    }
}
struct LoginResponse: Decodable {
    var name: String?
    var surname: String?
}
```

## Advanced usage
### Timeouts
By default, request timeouts are 60 seconds for request and resource which are relatively equivalent to `URLSessionConfiguration`'s `timeoutIntervalForRequest` and `timeoutIntervalForResource` parameters. Currently `Networking` supports timeouts to be set globally, so once changed new value will be applied to all next requests. Having different timeout for each single request is planned to be supported in the future to enable `Networkable` include `timeout` parameter.
```swift
NetworkableConfigs.default.setTimeout(for: 30, resource: 30)
```

### SSL Pinning
`Networking`, like setting timeout, supports only global certificates set via:
```swift
if let path = Bundle.main.path(forResource: "certificate", ofType: "der") {
    NetworkableConfigs.default.setCertificatePaths(path)
}
```

### Enable server-trusted authentication.
`Networking` can be configured to continue with any challenge, in case your server has no publicly trusted certifiace.
**Apple may reject your application, for this usage. It's on your own responsibility**
```swift
NetworkableConfigs.default.setServerTrustedURLAuthenticationChallenge()
```

### File Upload
`Networking` supports file upload through `uploadRequest` using `MBNetworking.File`s.
```swift
extension API {
    enum File: Networkable {
        /// Multipart file upload request.
        case upload(parameters: [String: String], files: [MBNetworking.File])
        
        var request: URLRequest {
            switch self {
            case let .upload(parameters, files):
                return uploadRequest(url: API.getURL(endpoint: "FileUpload"),
                                     parameters: parameters, files: files)
            }
        }
    }
}
```

### Data Download
You can use `Data` type as decodable to download Data from service. This can be helpful for downloading image, html data.
```swift
extension API {
    enum Download: Networkable {
        case image(url: URL)
        
        var request: URLRequest {
            switch self {
            case let .image(url):
                return getRequest(url: url, queryItems: [:])
            }
        }
    }
}
```

### Unit Testing
Networking provides `StubURLProtocol` which acts like man-in-the-middle to simplify stub data for unit testing. You can achieve this by setting `StubURLProtocol.result` to a any of the available values which are:
* success(Data): Successfull result with specified data
* failure(Error): Failure with the specified Error.
* case failureStatusCode(Int): Failure with the specified status code.

There're helper functions to get the `StubURLProtocol.Result` with the data from specified bundle resource. 
```swift
StubURLProtocol.result = .getData(from: Bundle.module.url(forResource: "some", withExtension: "txt"))
StubURLProtocol.result = .getData(from: Bundle.module.path(forResource: "some", ofType: "txt"))
```

You can define a delay in seconds for reading stub data:
```swift
StubURLProtocol.delay = 3
```

StubURLProtocol is designed for **unit tests only** and would not work if there's no any unit testing process in progress.

You need to set `StubURLProtocol.result` before each `Networkable.fetch` call to achieve necessary result.

### Task Cancellation
Networking supports canceling ongoing requests. It can be helpful when you need to cancel all fired requests without waiting to respond them.
```swift
NetworkableTasks.cancelAll()
```
After calling ```cancelAll()``` function, ongoing requeste returns ```NetworkingError.dataTaskCancelled``` in their ```failure``` block immediately.  
