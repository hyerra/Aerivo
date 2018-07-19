//
//  NWQPEndpoint.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/17/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the endpoints that belong to the National Water Quality Endpoint.
public enum NWQPEndpoint: Endpoint {
    case stations(parameters: NWQPParameters)
    case results(parameters: NWQPParameters)
    case activityData(parameters: NWQPParameters)
    case activityMetricData(parameters: NWQPParameters)
    
    var baseURL: URL {
        return URL(string: "https://www.waterqualitydata.us")!
    }
    
    var path: String {
        switch self {
        case .stations: return "data/Station/search"
        case .results: return "data/Result/search"
        case .activityData: return "data/Activity/search"
        case .activityMetricData: return "data/ActivityMetric/search"
        }
    }
    
    var version: Float {
        return 1.0
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Data? {
        switch self {
        case .stations(let params): return try? convert(parameters: params)
        case .results(let params): return try? convert(parameters: params)
        case .activityData(let params): return try? convert(parameters: params)
        case .activityMetricData(let params): return try? convert(parameters: params)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
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
        encoder.dateEncodingStrategy = .nwqpFormat
        let json = try encoder.encode(parameters)
        return json
    }
}
