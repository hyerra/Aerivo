//
//  CivicInformationEndpoint.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the endpoints that belong to Google's Civic Information.
public enum CivicInformationEndpoint: Endpoint {
    case representativeInfoByAddress(parameters: RepresentativeInfoByAddressParameters)
    
    var baseURL: URL {
        return URL(string: "https://www.googleapis.com/civicinfo")!
    }
    
    var version: String {
        return "2"
    }
    
    var path: String {
        switch self {
        case .representativeInfoByAddress: return "representatives"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Data? {
        switch self {
        case .representativeInfoByAddress(let params): return try? convert(parameters: params)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent("v\(version)").appendingPathComponent(path)
        var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        params: if let parameters = parameters {
            let dict = try JSONSerialization.jsonObject(with: parameters, options: []) as! [String: Any]
            guard !dict.isEmpty else { break params }
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
        encoder.dateEncodingStrategy = .iso8601FS
        let json = try encoder.encode(parameters)
        return json
    }
}
