//
//  ResultTestAPI.swift
//  Networking
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation
@testable import Networking

enum ResultTestAPI: Networkable {
    
    case fetch
    case underlyingError
    case httpError
    
    var request: URLRequest {
        switch self {
            
        case .fetch:
            let url = URL(forceString: "https://itunes.apple.com/search")
            return getRequest(url: url, queryItems: ["media": "music"])
        case .underlyingError:
            let url = URL(forceString: "https://iitunes.apple.com/search")
            return getRequest(url: url, queryItems: ["media": "music"])
        case .httpError:
            let url = URL(forceString: "https://itunes.apple.com/search")
            return getRequest(url: url, queryItems: ["media": "0"])
        }
        
    }
    
}
