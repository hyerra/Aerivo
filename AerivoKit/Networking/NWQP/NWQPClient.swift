//
//  NWQPClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a National Water Quality Portal client used to retrieve data from the National Water Quality Portal.
public final class NWQPClient: APIClient {
    
    /// Returns a `shared` singleton National Water Quality Portal Client object.
    public static let shared = NWQPClient()
    
    /// Returns a new instance of the National Water Quality Portal Client.
    public init() { }
    
    ///  Fetch the stations that are available from the National Water Quality Portal.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the stations.
    ///   - completion: If successful, the stations will be provided. If a failure occured, an error will be returned explaining what went wrong.
    /// - Returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting placemarks, cancel this task.
    @discardableResult
    public func fetchStations(using parameters: NWQPParameters, completion: @escaping(APIResult<NWQPStation>) -> Void) -> URLSessionDataTask {
        let nwqpStationEndpoint = NWQPEndpoint.stations(parameters: parameters)
        return connect(to: nwqpStationEndpoint, completion: completion)
    }
    
    /// Fetch the data that is available from the National Water Quality Portal.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the results.
    ///   - completion: If successful, the data will be provided. If a failure occured, an error will be returned explaining what went wrong.
    /// - Returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting placemarks, cancel this task.
    @discardableResult
    public func fetchResults(using parameters: NWQPParameters, completion: @escaping (APIResult<NWQPResult>) -> Void) -> URLSessionDataTask {
        let nwqpResultEndpoint = NWQPEndpoint.results(parameters: parameters)
        return connect(to: nwqpResultEndpoint, completion: completion)
    }
    
    /// Fetches all the characteristic names that are supported by Aerivo and are available from the National Water Quality Portal.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the results. The `characteristicName` will be ignored as it'll be supplied by this method to fetch all the characteristic names supported.
    ///   - completion: If successful, the data will be provided. If a failure occured, an error will be returned explaining what went wrong.
    /// - Returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting placemarks, cancel this task.
    @discardableResult
    public func fetchAllResults(using parameters: NWQPParameters, completion: @escaping ([APIResult<NWQPResult>]) -> Void) -> [URLSessionDataTask] {
        var responses: [APIResult<NWQPResult>] = []
        let totalExpectedResponses = NWQPParameters.CharacteristicName.allCases.count
        
        var tasks: [URLSessionDataTask] = []
        
        var modifiedParameters = parameters
        for parameter in NWQPParameters.CharacteristicName.allCases {
            modifiedParameters.characteristicName = parameter
            let task = fetchResults(using: modifiedParameters) {
                responses.append($0)
                if responses.count == totalExpectedResponses { completion(responses) }
            }
            tasks.append(task)
        }
        
        return tasks
    }
    
    // MARK: - API client
    
    @discardableResult
    func connect(to request: URLRequestConvertible, completion: @escaping (NetworkingResponse) -> Void) -> URLSessionDataTask {
        let request = request.asURLRequest()
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            #if DEBUG
            print(response as Any)
            #endif
            DispatchQueue.main.async {
                completion((data, response, error))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    @discardableResult
    func connect<T>(to request: URLRequestConvertible, parse: ((NetworkingResponse) -> APIResult<T>)? = nil, completion: @escaping (APIResult<T>) -> Void) -> URLSessionDataTask {
        return connect(to: request) { response in
            if let parse = parse {
                let parsedValue = parse(response)
                completion(parsedValue)
            } else {
                let decoder = XMLDecoder()
                decoder.dateDecodingStrategy = .nwqpFormat
                guard let data = response.data else { completion(.failure(response.error!)); return }
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
}
