//
//  File.swift
//  
//
//  Created by BV Harsha on 2024-06-26.
//

import Foundation


public enum NetworkServiceError: Error {
   // error cases
    case badURLString
    case requestFailed(Error)
    case decodingFailed(Error)
    case badHTTPResponseCode(Int)
    case unknown
    case badFormattedURL
}

 extension NetworkServiceError:CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "An unknown error has occured"
        case .badFormattedURL: return "The URL is badly formatted"
        case .badHTTPResponseCode(let code): return "The response code is not acceptable , response: \(code)"
        case .badURLString: return "The URL String is wrong"
        case .requestFailed(let requestError): return "The request has failed. Error: \(requestError.localizedDescription)"
        case .decodingFailed(let decodingError): return "The decoding has failed. Errorr: \(decodingError.localizedDescription)"
        }
    }
}

extension NetworkServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown: return NSLocalizedString("An unknown error has occured", comment: "Unknown error")
        case .badFormattedURL: return NSLocalizedString("The URL is badly formatted", comment: "BadFormattedURL")
        case .badHTTPResponseCode(let code): return NSLocalizedString("The response code is not acceptable , response: \(code)", comment: "BadHttpResponseCode")
        case .badURLString: return NSLocalizedString("The URL construct is wrong", comment: "BadURLString")
        case .requestFailed(let requestError): return NSLocalizedString("The request has failed. Error: \(requestError.localizedDescription)", comment: "RequestFailed")
        case .decodingFailed(let decodingError): return NSLocalizedString("The decoding has failed. Errorr: \(decodingError.localizedDescription)", comment: "DecodingFailed")
        }
    }
}
