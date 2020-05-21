//
//  NetworkingError.swift
//  Networking
//
//  Created by Eren Bayrak on 8.05.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation

public enum NetworkingError: Error {
    
    /// Indicates a response failed for cannot connect `Internet Network`.
    case networkConnectionError(Error?)
    
    /// Indicates a response failed to map to a `Decodable` object.
    case decodingError(Error, URLResponse?)
    
    /// Indicates a response failed with an invalid `HTTP Status Code`.
    case httpError(Error?, HTTPURLResponse)
    
    /// Indicates a response didn't find `Data`.
    case dataTaskError(URLResponse, Data?)
    
    /// Indicates a response failed due to an underlying `Error`.
    case underlyingError(Error, URLResponse?)
    
    /// Indicates a response failed unkown`Error`.
    case unkownError(Error?)
}

extension NetworkingError {
    
    var errorTitle: String {
        switch self {
        case .networkConnectionError: return "Network Connection Error"
        case .decodingError: return "Decoding Error"
        case .httpError: return "HTTP Error"
        case .dataTaskError: return "Data Task Error"
        case .underlyingError: return "Underlying Error"
        case .unkownError: return "Unkown Error"
        }
    }
    
    var response: URLResponse? {
        switch self {
        case .networkConnectionError: return nil
        case .decodingError(_, let response): return response
        case .httpError(_, let response): return response
        case .dataTaskError(let response, _): return response
        case .underlyingError(_, let response): return response
        case .unkownError: return nil
        }
    }
    
    var errorDescription: String {
        switch self {
        case .networkConnectionError(let error):
            return "\n Colundn't connect internet network. \n\(error?.localizedDescription ?? "")"
        case .decodingError(let error, _):
            return error.localizedDescription
        case .httpError(let error, let response):
            return "\nStatus Code: \(response.statusCode.description) \n\(error?.localizedDescription ?? "")\n"
        case .dataTaskError:
            return "Couldn't find data."
        case .underlyingError(let error, _):
            return error.localizedDescription
        case .unkownError(let error):
            return error?.localizedDescription ?? "Unkown Error"
        }
    }
}
