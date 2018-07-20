//
//  NWQPClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a National Water Quality Portal client used to retrieve data from the National Water Quality Portal.
public class NWQPClient: APIClient {
    
    /// Returns a `shared` singleton National Water Quality Portal Client object.
    public static let shared = NWQPClient()
    
    /// Returns a new instance of the National Water Quality Portal Client.
    public init() { }
    
    /// Fetch the stations that are available from the National Water Quality Portal.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the stations.
    ///   - completion: If successful, the stations will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchStations(using parameters: NWQPParameters, completion: @escaping(APIResult<NWQPStation>) -> Void) {
        let nwqpStationEndpoint = NWQPEndpoint.stations(parameters: parameters)
        connect(to: nwqpStationEndpoint, completion: completion)
    }
    
    /// Fetch the data that is available from the National Water Quality Portal.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the results.
    ///   - completion: If successful, the data will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchResults(using parameters: NWQPParameters, completion: @escaping (APIResult<NWQPResult>) -> Void) {
        let nwqpResultEndpoint = NWQPEndpoint.results(parameters: parameters)
        connect(to: nwqpResultEndpoint, completion: completion)
    }
    
    // MARK: - API client
    
    func connect(to request: URLRequestConvertible, completion: @escaping (NetworkingResponse) -> Void) {
        do {
            let request = try request.asURLRequest()
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: request) { data, response, error in
                #if DEBUG
                print(response as Any)
                #endif
                completion((data, response, error))
            }
            
            dataTask.resume()
        } catch let error {
            completion((nil, nil, error))
        }
    }
    
    func connect<T>(to request: URLRequestConvertible, parse: ((NetworkingResponse) -> APIResult<T>)? = nil, completion: @escaping (APIResult<T>) -> Void) {
        connect(to: request) { response in
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
