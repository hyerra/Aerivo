//
//  AQFetch.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a fetch used by Open AQ to populate their data.
public struct Fetch: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the fetch.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the fetch.
    public struct Result: Codable {
        /// The count of new, inserted measurements.
        var count: Int
        /// Metadata about the source of each fetch task.
        var results: [Result]
        /// The start time of each fetch task.
        var timeStarted: Date
        /// The end time of each fetch task.
        var timeEnded: Date
        
        /// Represents the result data that provides more information about the source of each fetch.
        public struct Result: Codable {
            /// A message about the fetch.
            var message: String
            /// The count of new, inserted measurements.
            var count: Int
            /// The duration of each fetch.
            var duration: Double
            /// The name of the source of the fetch.
            var sourceName: String
        }
    }
}
