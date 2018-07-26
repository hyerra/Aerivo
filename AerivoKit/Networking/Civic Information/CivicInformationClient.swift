//
//  CivicInformationClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a Civic Information client used to retrieve representative information from Google's Civic Information.
public class CivicInformationClient: APIClient {
    
    /// Fetches political geography and representative information for a single address.
    ///
    /// - Parameters:
    ///   - parameters: Parameters that can be specified when fetching the representative information from the Google's Civic Information.
    ///   - completion: If successful, the representative information will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchRepresentativeInfo(using parameters: RepresentativeInfoByAddressParameters, completion: @escaping (APIResult<RepresentativeInfoByAddress>) -> Void) {
        let representativeInfoEndpoint = CivicInformationEndpoint.representativeInfoByAddress(parameters: parameters)
        connect(to: representativeInfoEndpoint, completion: completion)
    }
    
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let data = response.data else { completion(.failure(response.error!)); return }
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch let error {
                    guard let aqError = try? decoder.decode(OpenAQError.self, from: data) else { completion(.failure(error)) ;return }
                    completion(.failure(aqError))
                }
            }
        }
    }
}
