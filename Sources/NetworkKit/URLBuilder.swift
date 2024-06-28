//
//  File.swift
//  
//
//  Created by BV Harsha on 2024-06-26.
//

import Foundation
import UIKit


// Defining the interface

public protocol URLBuilderInterface {
    func buildURL() -> URL?
    func isValidURL() throws -> Bool
}

// Struct

public struct URLComponentsBuilder: URLBuilderInterface {
    
   // URL Components
    var scheme: String 
    var host: String
    var path: String
    var queryItems: [URLQueryItem]?
    
    public init(scheme: String, host: String, path: String, queryItems: [URLQueryItem]? = nil) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }
    
    public func buildURL() -> URL? {
        // defining components
        var components = URLComponents()
        components.queryItems = queryItems
        components.host = host
        components.path = path
        components.scheme = scheme
        return components.url
    }
    
    public func isValidURL() throws -> Bool {
        // only https secure calls are allowed
        guard let url = buildURL() else {throw NetworkServiceError.badURLString}
        return (url.scheme == "https" && url.host != "") ? true : false
    }
}
