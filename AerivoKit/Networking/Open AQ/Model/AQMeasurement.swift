//
//  AQMeasurement.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents data about an individual measurement.
public struct Measurement: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the measurement info.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the measurements.
    public struct Result: Codable {
        /// The name of the parameter.
        public var parameter: String
        /// The value of the measurment.
        public var value: Double
        /// The unit of the measurment.
        public var unit: AirQualityUnitCode
        /// The location name of the measurment.
        public var location: String
        /// The two letter ISO country code for the measurement.
        public var isoCountryCode: String
        /// The city the measurement was taken in.
        public var city: String
        /// The coordinates of where the measurement was taken in.
        public var coordinates: CodableCoordinate?
        /// The name of the source matching to sources table for reference.
        public var sourceName: String?
        /// The attribution information for this measurement.
        public var attribution: Attribution?
        /// The averaging period information for this measurement.
        public var averagingPeriod: AveragingPeriod?
        
        /// Represents the attribution information for this measurement.
        public struct Attribution: Codable {
            /// The name to attribute the measurement to.
            public var name: String
            /// A url to the homepage of the source.
            public var url: URL?
        }
        
        /// Represents the averaging period for this measurement.
        public struct AveragingPeriod: Codable {
            /// The value of the time.
            public var value: Double
            /// The unit this time is in.
            public var unit: String
        }
        
        private enum CodingKeys: String, CodingKey {
            case parameter
            case value
            case unit
            case location
            case isoCountryCode = "country"
            case city
            case coordinates
            case sourceName
            case attribution
            case averagingPeriod
        }
    }
}
