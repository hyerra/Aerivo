//
//  OpenAQClient.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents an Open AQ client used to retrieve data from Open AQ.
public final class OpenAQClient: APIClient {
    
    /// Returns a `shared` singleton Open AQ Client object.
    public static let shared = OpenAQClient()
    
    /// Returns a new instance of the Open AQ Client.
    public init() { }
    
    /// Fetches a listing of cities supported in Open AQ.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the cities.
    ///   - completion: If successful, the cities will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchCities(using parameters: CitiesParameters, completion: @escaping (APIResult<City>) -> Void) {
        let citiesEndpoint = OpenAQEndpoint.fetchCities(parameters: parameters)
        connect(to: citiesEndpoint, completion: completion)
    }
    
    /// Fetches a listing of countries supported in Open AQ.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the countries.
    ///   - completion: If successful, the countries will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchCountries(using parameters: CountriesParameters, completion: @escaping (APIResult<Country>) -> Void) {
        let countriesEndpoint = OpenAQEndpoint.fetchCountries(parameters: parameters)
        connect(to: countriesEndpoint, completion: completion)
    }
    
    /// Fetches a list of fetches that are used to populate the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the list of fetches that are used to populate the Open AQ platform.
    ///   - completion: If successful the fetches will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func retrieveFetches(using parameters: FetchParameters, completion: @escaping (APIResult<Fetch>) -> Void) {
        let fetchEndpoint = OpenAQEndpoint.retrieveFetches(parameters: parameters)
        connect(to: fetchEndpoint, completion: completion)
    }
    
    /// Fetches a list of the latest value of each parameter for a location in the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the latest air quality data.
    ///   - completion: If successful, the latest air quality data will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchLatestAQ(using parameters: LatestAQParameters, completion: @escaping (APIResult<LatestAQ>) -> Void) {
        let latestAQEndpoint = OpenAQEndpoint.fetchLatestAQ(parameters: parameters)
        connect(to: latestAQEndpoint, completion: completion)
    }
    
    /// Fetches a list of air monitoring locations in the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the location data.
    ///   - completion: If successful, the location data will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchLocations(using parameters: LocationsParameters, completion: @escaping (APIResult<Location>) -> Void) {
        let locationEndpoint = OpenAQEndpoint.fetchLocations(parameters: parameters)
        connect(to: locationEndpoint, completion: completion)
    }
    
    /// Fetches data about individual measurements in the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to be used when fetching the measurement data.
    ///   - completion: If successful, the measurement info will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchMeasurementsInfo(using parameters: MeasurementsParameters, completion: @escaping (APIResult<Measurement>) -> Void) {
        let measurementEndpoint = OpenAQEndpoint.fetchMeasurementsInfo(parameters: parameters)
        connect(to: measurementEndpoint, completion: completion)
    }
    
    /// Fetches a simple listing of the parameters in the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters that can be specified when fetching the Open AQ parameters.
    ///   - completion: If successful, the parameters that are used within the Open AQ platform will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchParameters(using parameters: ParameterParameters, completion: @escaping (APIResult<Parameter>) -> Void) {
        let parameterEndpoint = OpenAQEndpoint.fetchParameters(parameters: parameters)
        connect(to: parameterEndpoint, completion: completion)
    }
    
    /// Fetches a list of data sources used to populate data in the Open AQ platform.
    ///
    /// - Parameters:
    ///   - parameters: Parameters that can be specified when fetching the data sources in the Open AQ platform.
    ///   - completion: If successful, the data sources that are used within the Open AQ platform will be provided. If a failure occured, an error will be returned explaining what went wrong.
    public func fetchSources(using parameters: SourcesParameters, completion: @escaping (APIResult<Source>) -> Void) {
        let sourcesEndpoint = OpenAQEndpoint.fetchSources(parameters: parameters)
        connect(to: sourcesEndpoint, completion: completion)
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601FS
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
