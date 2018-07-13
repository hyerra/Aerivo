//
//  Endpoint.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
protocol URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - Returns: An `Error` if the underlying `URLRequest` is `nil`.
    /// - Throws: A URL request.
    func asURLRequest() throws -> URLRequest
}

/// [HTTP Method Information](https://tools.ietf.org/html/rfc7231#section-4.3)
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

/// Represents an Endpoint for networking.
protocol Endpoint: URLRequestConvertible {
    /// The url without any parameters or paths.
    var baseURL: URL { get }
    /// The version of the API.
    var version: Float { get }
    /// The path to the resource.
    var path: String { get }
    /// The HTTP Method to use for the request.
    var method: HTTPMethod { get }
    /// The parameters to send with the request.
    var parameters: Data? { get }
}

extension Endpoint {
    /// Converts `parameters` to `Data` for use with `URLRequest`.
    ///
    /// - Parameter parameters: The parameters to be encoded.
    /// - Returns: The data that was generated from the parameters.
    /// - Throws: An error that explains what went wrong in the encoding process.
    func convert<EncodableType: Encodable>(parameters: EncodableType) throws -> Data {
        let encoder = JSONEncoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        return try encoder.encode(parameters)
    }
}
