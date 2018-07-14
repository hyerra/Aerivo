//
//  AQCountry.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a country within Open AQ.
public struct Country: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the country data.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the country data.
    public struct Result: Codable {
        /// The two letter iso code of the country.
        public var isoCode: String
        /// The name of the country.
        public var name: String
        /// The number of air quality measurements taken for this country.
        public var measurementCount: Int
        /// The number of cities that are monitored in Open AQ for this country.
        public var numberOfCities: Int
        /// The number of locations (air monitoring stations) in the country.
        public var locationCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case isoCode = "code"
            case name
            case measurementCount = "count"
            case numberOfCities = "cities"
            case locationCount = "locations"
        }
    }
}

// MARK: - Equatable

extension Country.Result: Equatable {
    public static func == (lhs: Country.Result, rhs: Country.Result) -> Bool {
        return lhs.isoCode == rhs.isoCode
    }
}
