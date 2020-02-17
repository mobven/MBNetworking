# Networking

Networking framework based on `URLSession.dataTask()`.   

## Requirements

- iOS 10.0+
- Xcode 11.3+
- Swift 5+
- Swift Package Manager

## Installation

### Swift Package Manager
Framework is supported only via Swift Package Manager and is not planned to be distributed otherwise, unless there is a specific requirement. As Swift Package Manager is stable currently and there is an active development on it which promises it will be used for a while.

Project can be installed using SPM with its github URL.
```bash
https://github.com/mobven/Networking
```

## Usage
Networking framework has been evolved from the idea of replacing `Alamofire` (in some projects also `Moya`) with native `URLSession` functions. Its functionalities can be achieved creating enums which conform to `Networkable` protocol and overriding its `request` parameter. Later, when `fetch` called  `Networkable` uses this `request` to proceed the request.  

### Creating Networkables
```swift
import Networking
enum API {
    enum Login: Networkable {
        /// Login with username and password
        case login(request: LoginRequest)
        
        var request: URLRequest {
            switch self {
            case .login(let request):
                return getRequest(url: API.getURL(endpoint: "Login"),
                                  encodable: request)
            }
        }
    }
    
    private static func getURL(endpoint: String) -> URL {
        let baseEndpoint = Bundle.main.infoForKey("BASE_URL") ?? ""
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
API.Auth.login(request: request).fetch { (response: LoginResponse, error: Error) in
    
}
struct LoginResponse: Decodable {
    var name: String?
    var surname: String?
}
```

## Advanced usage
// TODO: Requests timeouts, SSL pinning and etc. 
