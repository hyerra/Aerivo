//
//  APIClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// The result of the API Request.
///
/// - success: The request was successfully executed with a result.
/// - failure: The request failed with an error.
public enum APIResult<ResultType: Decodable> {
    case success(ResultType)
    case failure(Error)
}

/// The response that is given back after making a network request.
public typealias NetworkingResponse = (data: Data?, response: URLResponse?, error: Error?)

/// Represents an `APIClient` to connect to endpoints and fetch data.
protocol APIClient {
    
    /// Connects to a server at the specified endpoint and fetches the response data.
    ///
    /// - Parameters:
    ///   - request: The url request you wish to connect to.
    ///   - completion: The result of the request.
    /// - Returns: The data for you to parse and handle.
    func connect(to request: URLRequestConvertible, completion: @escaping (NetworkingResponse) -> Void)
    
    /// Connects to a server at the specified endpoint and fetches response converted to a usable object.
    ///
    /// - Parameters:
    ///   - request: The url request you wish to connect to.
    ///   - parse: How you wish to parse the data. If `nil` is provided we will attempt to use a `JSONDecoder`.
    ///   - completion: An APIResult for you to handle and use.
    func connect<T>(to request: URLRequestConvertible, parse: ((NetworkingResponse) -> APIResult<T>)?, completion: @escaping (APIResult<T>) -> Void)
}
