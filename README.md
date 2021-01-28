# Networking

Networking is a design-pattern framework based on Apple's `URLSession`. It's evolved from the idea of replacing `Alamofire` (in some projects also `Moya`) with native `URLSession` functions.

## Requirements

- iOS 9.0+
- Xcode 11.3+
- Swift 5+

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
            case .loginGet(let username, let password):
                return getRequest(url: API.getURL(endpoint: "LoginPOST"),
                                  queryItems: ["username": username, "password": password])
            case .loginPost(let request):
                return getRequest(url: API.getURL(endpoint: "LoginGET"),
                                  encodable: request)
            }
        }
    }
    
    enum File: Networkable {
        /// Multipart file upload request.
        case upload(parameters: [String: String], files: [MBNetworking.File])
        
        var request: URLRequest {
            switch self {
            case .upload(let parameters, let files):
                return uploadRequest(url: API.getURL(endpoint: "FileUpload"),
                                     parameters: parameters, files: files)
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
    case .success(let response):
        print("Succeeded with \(response)")
    case .failure(let error):
        print("Failed with \(error)")
    }
}
API.Login.loginPost(request: LoginRequest(username: "admin", password: "admin")).fetch(LoginResponse.self) { result in
    switch result {
    case .success(let response):
        print("Succeeded with \(response)")
    case .failure(let error):
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
