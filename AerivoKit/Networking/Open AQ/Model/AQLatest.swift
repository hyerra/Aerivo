//
//  AQLatest.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// The latest Open AQ Data for a location.
public struct Latest: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the latest measurement data.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the latest measurement data.
    public struct Result: Codable {
        /// The identifier for a location.
        public var location: String
        /// The name of the city for the location.
        public var city: String
        /// The two letter ISO code of the country.
        public var isoCountryCode: String
        /// The latest measurements for this location.
        public var measurements: [Measurement]
        
        /// Represents a measurement for this location.
        public struct Measurement: Codable {
            /// The parameter of which air quality attribute was being measured.
            public var parameter: AirQualityParameter
            /// The value of the parameter.
            public var value: Double
            /// The last time the measurement was updated.
            public var lastUpdated: Date
            /// The unit of the parameter.
            public var unit: String
            /// The name of where the measurement originated from.
            public var sourceName: String
        }
        
        private enum CodingKeys: String, CodingKey {
            case location
            case city
            case isoCountryCode = "country"
            case measurements
        }
    }
}
