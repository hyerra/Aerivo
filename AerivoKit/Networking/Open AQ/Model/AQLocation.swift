//
//  AQLocation.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents a location that is used to measure air quality within Open AQ.
public struct Location: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the location data.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the locations.
    public struct Result: Codable {
        /// The location identifier.
        public var id: String
        /// The two letter ISO code of the country.
        public var isoCountryCode: String
        /// The city containing the location.
        public var city: String
        /// The number of measurements, cumulative by specificity level.
        public var count: Int
        /// Distance to the specified coordinates, present when `coordinates` was sent with the request.
        public var distance: Double?
        /// Can follow this to determine active adapter used for this location.
        public var sourceName: String
        /// When the data was first used from this location.
        public var firstUpdated: Date
        /// When the data was last used from this location.
        public var lastUpdated: Date
        /// List of parameters present for this location.
        public var parameters: [AirQualityParameter]
        /// The coordinates of the location.
        public var coordinates: CodableCoordinate?
        
        private enum CodingKeys: String, CodingKey {
            case id = "location"
            case isoCountryCode = "country"
            case city
            case count
            case distance
            case sourceName
            case firstUpdated
            case lastUpdated
            case parameters
            case coordinates
        }
    }
    
}

// MARK: - Equatable

extension Location.Result: Equatable {
    public static func == (lhs: Location.Result, rhs: Location.Result) -> Bool {
        return lhs.id == rhs.id
    }
}
