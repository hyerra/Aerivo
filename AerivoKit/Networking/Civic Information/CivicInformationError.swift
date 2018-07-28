//
//  CivicInformationError.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/27/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents an error that was raised by calling Google's Civic Information.
public struct CivicInformationError: Codable, Error {
    /// The errors that were returned by Google's Civic Information.
    public var errors: [ErrorDescription]
    /// The error code that was returned by Google's Civic Information.
    public var code: Int
    /// The message that was returned by Google's Civic Information.
    public var message: String
    
    /// Represents an error description for each error raised by Google's Civic Information.
    public struct ErrorDescription: Codable {
        /// The domain of the error.
        public var domain: String
        /// The reason for the error.
        public var reason: String
        /// A message about the error.
        public var message: String
        /// The type of the location of the error.
        public var locationType: String
        /// The location of the error.
        public var location: String
    }
}
