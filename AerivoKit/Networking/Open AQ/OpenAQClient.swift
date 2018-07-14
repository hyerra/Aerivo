//
//  OpenAQClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents an Open AQ client used to retrieve data from Open AQ.
public class OpenAQClient: APIClient {
    
    /// Returns a `shared` singleton Open AQ Client object.
    static let shared = OpenAQClient()
    
    /// Returns a new instance of Open AQ Client.
    private init() { }
    
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
                do {
                    let decoder = JSONDecoder()
                    guard let data = response.data else { completion(.failure(response.error!)); return }
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
}
