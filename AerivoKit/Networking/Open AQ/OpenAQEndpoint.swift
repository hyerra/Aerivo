//
//  OpenAQEndpoint.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the endpoints that belong to Open AQ.
enum OpenAQEndpoint: Endpoint {
    
    case fetchCities(parameters: CitiesParameters)
    case fetchCountries(parameters: CountriesParameters)
    case retrieveFetches(parameters: FetchParameters)
    case fetchLatestAQ(parameters: LatestAQParameters)
    case fetchLocations(parameters: LocationsParameters)
    case fetchMeasurementsInfo(parameters: MeasurementsParameters)
    case fetchParameters(parameters: ParameterParameters)
    case fetchSources(parameters: SourcesParameters)
    
    var baseURL: URL {
        return URL(string: "https://api.openaq.org")!
    }
    
    var version: String {
        return "1"
    }
    
    var path: String {
        switch self {
        case .fetchCities: return "cities"
        case .fetchCountries: return "countries"
        case .retrieveFetches: return "fetches"
        case .fetchLatestAQ: return "latest"
        case .fetchLocations: return "locations"
        case .fetchMeasurementsInfo: return "measurements"
        case .fetchParameters: return "parameters"
        case .fetchSources: return "sources"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Data? {
        switch self {
        case .fetchCities(parameters: let params): return try? convert(parameters: params)
        case .fetchCountries(parameters: let params): return try? convert(parameters: params)
        case .retrieveFetches(parameters: let params): return try? convert(parameters: params)
        case .fetchLatestAQ(parameters: let params): return try? convert(parameters: params)
        case .fetchLocations(parameters: let params): return try? convert(parameters: params)
        case .fetchMeasurementsInfo(parameters: let params): return try? convert(parameters: params)
        case .fetchParameters(parameters: let params): return try? convert(parameters: params)
        case .fetchSources(parameters: let params): return try? convert(parameters: params)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent("v\(version)").appendingPathComponent(path)
        var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        params: if let parameters = parameters {
            let dict = try JSONSerialization.jsonObject(with: parameters, options: []) as! [String: Any]
            guard !dict.isEmpty else { break params }
            urlComps.queryItems = dict.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        var urlRequest = URLRequest(url: urlComps.url!)
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
