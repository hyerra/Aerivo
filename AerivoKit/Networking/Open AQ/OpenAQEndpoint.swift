//
//  OpenAQEndpoint.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the endpoints that belong to Open AQ.
protocol OpenAQEndpoint: Endpoint { }

extension OpenAQEndpoint {
    var baseURL: URL {
        return URL(string: "api.openaq.org")!
    }
    
    var version: Float {
        return 1
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent("v\(version)").appendingPathComponent(path)
        var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let parameters = parameters {
            let dict = try JSONSerialization.jsonObject(with: parameters, options: []) as! [String: Any]
            urlComps?.queryItems = dict.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        var urlRequest = URLRequest(url: urlComps!.url!)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
    
    /// Converts `parameters` to `Data` for use with `URLRequest`.
    ///
    /// - Parameter parameters: The parameters to be encoded.
    /// - Returns: The data that was generated from the parameters.
    /// - Throws: An error that explains what went wrong in the encoding process.
    func convert<EncodableType: Encodable>(parameters: EncodableType) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(parameters)
        return json
    }
}
