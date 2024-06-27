//
//  File.swift
//  
//
//  Created by BV Harsha on 2024-06-26.
//

import Foundation


// Defining the interface

public protocol URLBuilderInterface {
    func buildURL() -> URL?
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
        components.scheme = scheme
        components.path = path
        return components.url
    }
}
