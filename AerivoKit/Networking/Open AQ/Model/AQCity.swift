//
//  AQCity.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a city within Open AQ.
public struct City: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the city data.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the city data.
    public struct Result: Codable {
        /// The name of the city.
        public var name: String
        /// The two letter ISO code of the city.
        public var country: String
        /// The number of air quality measurements taken for this city.
        public var measurementCount: Int
        /// The number of locations (air monitoring stations) in the city.
        public var locationCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case name = "city"
            case country
            case measurementCount = "count"
            case locationCount = "locations"
        }
    }
    
}
