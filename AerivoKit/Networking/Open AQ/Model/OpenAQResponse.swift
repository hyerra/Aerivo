//
//  OpenAQResponse.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a response within Open AQ.
protocol OpenAQResponse: Decodable { }

/// Represents the information containing name, licensing info, etc.
public struct Meta: Codable {
    /// The name of the fetch.
    public var name: String
    /// The licensing info pertaining to the fetch.
    public var license: String
    /// A website linking to the source of the fetch.
    public var website: URL
    /// The page you are on for result pagination.
    public var page: Int?
    /// The maximum results that can be returned.
    public var limit: Int?
    /// The number of fetches found.
    public var found: Int?
}

/// The different parameters that can be used to measure air pollution.
public enum AirQualityParameter: String, Codable {
    case pm25
    case pm10
    case so2
    case no2
    case o3
    case co
    case bc
}
