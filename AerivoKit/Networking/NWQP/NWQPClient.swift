//
//  NWQPClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

public class NWQPClient: APIClient {
    
    public static let shared = NWQPClient()
    
    public init() { }
    
    public func fetchStations(using parameters: NWQPParameters, completion: @escaping(APIResult<NWQPStation>) -> Void) {
        let nwqpStationEndpoint = NWQPEndpoint.stations(parameters: parameters)
        connect(to: nwqpStationEndpoint, completion: completion)
    }
    
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
