//
//  AQParameter.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a simple listing of parameters within Open AQ.
public struct Parameter: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the fetch.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the parameters.
    public struct Result: Codable {
        /// The id of the parameter.
        public var id: String
        /// The name of the parameter.
        public var name: String
        /// The description pertaining to the parameter.
        public var description: String
        /// The parameter's prefered unit.
        public var preferredUnit: AirQualityUnitCode
    }
    
}

// MARK: - Equatable

extension Parameter.Result: Equatable {
    public static func == (lhs: Parameter.Result, rhs: Parameter.Result) -> Bool {
        return lhs.id == rhs.id
    }
}
