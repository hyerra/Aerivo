//
//  OpenAQParameters.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents parameters that should be used within Open AQ.
protocol OpenAQParameters: Parameters { }

// MARK: - Cities

/// Represents the parameters that can be used to fetch a simple listing of cities supported by Open AQ.
public struct AQCityParameters: OpenAQParameters {
    
    /// The countries to limit results by.
    public var country: String?
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    
    /// Represents the method to order results by.
    public enum OrderBy: String, Encodable {
        case city
        case country
        case count
        case locations
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case country
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
}

// MARK: - Countries

/// Represents the parameters that can be used to fetch a simple listing of countries supported by Open AQ.
public struct AQCountryParameters: OpenAQParameters {
    
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case isoCode = "code"
        case name
        case count
        case cities
        case locations
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
}

// MARK: - Fetch

/// Represents the parameters that can be used to provide data about individual fetch operations that are used to populate data on Open AQ.
public struct AQFetchParameters: OpenAQParameters {
    
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case timeStarted
        case timeEnded
        case count
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
}

// MARK: - Latest

/// Represents the parameters that can be used to fetch the latest air quality data.
public struct AQLatestParameters: OpenAQParameters {
    
    /// The city to limit results by.
    public var city: String?
    /// The country to limit results by.
    public var country: String?
    /// The location to limit results by.
    public var location: String?
    /// Limit results to a certain, specified parameter.
    public var parameter: AirQualityParameter?
    /// Whether or not to filter out results that don't have geographic information.
    public var hasGeo: Bool?
    /// Center point used to get results within a certain area. Must be used with `radius`.
    public var coordinates: CLLocationCoordinate2D?
    /// The radius used to get measurements within a certain area. Must be used with `coordinates`.
    public var radius: Int?
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    
    /// The different parameters that can be used to measure air pollution.
    public enum AirQualityParameter: String, Encodable {
        case pm25
        case pm10
        case so2
        case no2
        case o3
        case co
        case bc
    }
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case location
        case country
        case city
        case measurements
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case city
        case country
        case location
        case parameter
        case hasGeo = "has_geo"
        case coordinates
        case radius
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(location, forKey: .location)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(hasGeo, forKey: .hasGeo)
        if let coordinates = coordinates { try container.encode("\(coordinates.latitude),\(coordinates.longitude)", forKey: .coordinates) }
        try container.encode(radius, forKey: .radius)
        try container.encode(orderBy, forKey: .orderBy)
        try container.encode(sort, forKey: .sort)
        try container .encode(limit, forKey: .limit)
        try container.encode(page, forKey: .page)
    }
    
}

// MARK: - Locations

/// Represents the parameters that can be used to fetch the latest air quality data.
public struct AQLocationsParameters: OpenAQParameters {
    
    /// The city to limit results by.
    public var city: String?
    /// The country to limit results by.
    public var country: String?
    /// The location to limit results by.
    public var location: String?
    /// Limit results to a certain, specified parameter.
    public var parameter: AirQualityParameter?
    /// Whether or not to filter out results that don't have geographic information.
    public var hasGeo: Bool?
    /// Center point used to get results within a certain area. Must be used with `radius`.
    public var coordinates: CLLocationCoordinate2D?
    /// The radius used to get measurements within a certain area. Must be used with `coordinates`.
    public var radius: Int?
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    
    /// The different parameters that can be used to measure air pollution.
    public enum AirQualityParameter: String, Encodable {
        case pm25
        case pm10
        case so2
        case no2
        case o3
        case co
        case bc
    }
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case location
        case country
        case city
        case count
        case distance
        case sourceName
        case sourceNames
        case firstUpdated
        case lastUpdated
        case parameters
        case coordinates
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case city
        case country
        case location
        case parameter
        case hasGeo = "has_geo"
        case coordinates
        case radius
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(location, forKey: .location)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(hasGeo, forKey: .hasGeo)
        if let coordinates = coordinates { try container.encode("\(coordinates.latitude),\(coordinates.longitude)", forKey: .coordinates) }
        try container.encode(radius, forKey: .radius)
        try container.encode(orderBy, forKey: .orderBy)
        try container.encode(sort, forKey: .sort)
        try container .encode(limit, forKey: .limit)
        try container.encode(page, forKey: .page)
    }
    
}

// MARK: - Measurements

/// Represents the parameters that can be used to fetch data about individual measurements.
public struct AQMeasurementsParameters: OpenAQParameters {
    
    /// The country to limit results by.
    public var country: String?
    /// The city to limit results by.
    public var city: String?
    /// The location to limit results by.
    public var location: String?
    /// Limit results to a certain, specified parameter.
    public var parameter: AirQualityParameter?
    /// Whether or not to filter out results that don't have geographic information.
    public var hasGeo: Bool?
    /// Center point used to get results within a certain area. Must be used with `radius`.
    public var coordinates: CLLocationCoordinate2D?
    /// The radius used to get measurements within a certain area. Must be used with `coordinates`.
    public var radius: Int?
    /// Show results above value threshold. Should be used with `parameter`.
    public var valueFrom: Double?
    /// Show results below value threshold. Should be used with `parameter`.
    public var valueTo: Double?
    /// Show results after a certain date. Should be `iso8601` encoded.
    public var dateFrom: Date?
    /// Show results before a certain date. Should be `iso8601` encoded.
    public var dateTo: Date?
    /// The method to order results by.
    public var orderBy: OrderBy?
    /// The method to sort results by.
    public var sort: SortOrder?
    /// Include extra specified fields in addition to default values.
    public var includeFields: [Fields]?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The page you are on for result pagination.
    public var page: Int?
    /// The format to return the results in.
    public var format: Format?
    
    /// The different parameters that can be used to measure air pollution.
    public enum AirQualityParameter: String, Encodable {
        case pm25
        case pm10
        case so2
        case no2
        case o3
        case co
        case bc
    }
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case date
        case parameter
        case value
        case unit
        case location
        case country
        case city
        case coordinates
        case sourceName
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    /// Represents the fields that can be optionally requested.
    public enum Fields: String, Codable {
        case attribution
        case averagingPeriod
        case sourceName
    }
    
    /// Represents the format to return the results in.
    public enum Format: String, Codable {
        case json
        case csv
    }
    
    private enum CodingKeys: String, CodingKey {
        case country
        case city
        case location
        case parameter
        case hasGeo = "has_geo"
        case coordinates
        case radius
        case valueFrom = "value_from"
        case valueTo = "value_to"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case orderBy = "order_by"
        case sort
        case includeFields = "include_fields"
        case limit
        case page
        case format
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(country, forKey: .country)
        try container.encode(city, forKey: .city)
        try container.encode(location, forKey: .location)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(hasGeo, forKey: .hasGeo)
        if let coordinates = coordinates { try container.encode("\(coordinates.latitude),\(coordinates.longitude)", forKey: .coordinates) }
        try container.encode(radius, forKey: .radius)
        try container.encode(valueFrom, forKey: .valueFrom)
        try container.encode(valueTo, forKey: .valueTo)
        try container.encode(dateFrom, forKey: .dateFrom)
        try container.encode(dateTo, forKey: .dateTo)
        try container.encode(orderBy, forKey: .orderBy)
        try container.encode(sort, forKey: .sort)
        try container.encode(includeFields, forKey: .includeFields)
        try container .encode(limit, forKey: .limit)
        try container.encode(page, forKey: .page)
        try container.encode(format, forKey: .format)
    }
    
}

// MARK: - Parameters

/// Represents the parameters that can be used to fetch a simple listing of parameters within the Open AQ.
public struct AQParametersParameters: OpenAQParameters {
    public var orderBy: OrderBy?
    public var sort: SortOrder?
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case id
        case name
        case description
        case preferredUnit
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case orderBy = "order_by"
        case sort
    }
}

// MARK: - Sources

/// Represents the parameters that can be used to fetch a list of data sources.
public struct AQSourcesParameters: OpenAQParameters {
    public var orderBy: OrderBy?
    public var sort: SortOrder?
    public var limit: Int?
    public var page: Int?
    
    /// Represents the field to order results by.
    public enum OrderBy: String, Encodable {
        case url
        case adapter
        case name
        case city
        case country
        case description
        case resolution
        case sourceURL
        case contacts
        case active
    }
    
    /// Represents the method to sort results by.
    public enum SortOrder: String, Codable {
        case ascending = "asc"
        case decending = "desc"
    }
    
    private enum CodingKeys: String, CodingKey {
        case orderBy = "order_by"
        case sort
        case limit
        case page
    }
}
