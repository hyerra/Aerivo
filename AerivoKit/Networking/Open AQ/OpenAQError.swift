//
//  OpenAQError.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents an error that was raised by calling Open AQ.
public struct OpenAQError: Codable, Error {
    /// The status code of the error.
    public var statusCode: Int
    /// The error's name.
    public var error: String
    /// The error's message.
    public var message: String?
}
