//
//  AQSource.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a list of data sources for Open AQ.
public struct Source: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the source information.
    public var results: [Result]
    
    /// The result data that provides the contents of the source information.
    public struct Result: Codable {
        /// The actual data source URL.
        public var url: URL
        /// Name of the adapter that collects data from the source.
        public var adapter: String
        /// The name of the source.
        public var name: String
        /// The city where the data is being gathered.
        public var city: String
        /// The two letter ISO country code where the data is being gathered.
        public var isoCountryCode: String
        /// A description of the data source.
        public var description: String
        /// A URL about the source.
        public var sourceURL: URL
        /// Addresses you can send inquiries about the source.
        public var contacts: [String]
        /// Whether the source is used at this time.
        public var active: Bool
        
        private enum CodingKeys: String, CodingKey {
            case url
            case adapter
            case name
            case city
            case isoCountryCode = "country"
            case description
            case sourceURL
            case contacts
            case active
        }
    }
}
