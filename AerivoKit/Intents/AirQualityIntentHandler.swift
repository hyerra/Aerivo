//
//  AirQualityIntentHandler.swift
//  AerivoKit
//
//  Created by Harish Yerra on 8/11/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

@available(iOS 12.0, watchOS 5.0, *)
public class AirQualityIntentHandler: NSObject, AirQualityIntentHandling {    
    public func handle(intent: AirQualityIntent, completion: @escaping (AirQualityIntentResponse) -> Void) {
        guard let location = intent.targetLocation else { completion(AirQualityIntentResponse(code: .failure, userActivity: nil)); return }
        let openAQClient = OpenAQClient()
        
        var isParametersInfoLoaded = false
        var isAQDataLoaded = false
        
        var parametersInfo: Parameter?
        var latestAQInfo: LatestAQ?
        
        let parametersParams = ParameterParameters()
        openAQClient.fetchParameters(using: parametersParams) { result in
            guard case let .success(parameters) = result else { return }
            parametersInfo = parameters
            isParametersInfoLoaded = true
            if isParametersInfoLoaded && isAQDataLoaded {
                if let parametersInfo = parametersInfo, let latestAQInfo = latestAQInfo {
                    self.handleRequest(targetLocation: location, parameter: parametersInfo, latestAQ: latestAQInfo, completion: completion)
                } else {
                    completion(AirQualityIntentResponse(code: .failure, userActivity: nil)); return
                }
            }
        }
        
        var latestAQParams = LatestAQParameters()
        latestAQParams.coordinates = location.location?.coordinate
        latestAQParams.radius = 800000
        latestAQParams.orderBy = .distance
        latestAQParams.limit = 1
        openAQClient.fetchLatestAQ(using: latestAQParams) { result in
            guard case let .success(latestAQ) = result else { completion(AirQualityIntentResponse(code: .failure, userActivity: nil)); return }
            latestAQInfo = latestAQ
            isAQDataLoaded = true
            if isParametersInfoLoaded && isAQDataLoaded {
                if let parametersInfo = parametersInfo, let latestAQInfo = latestAQInfo {
                    self.handleRequest(targetLocation: location, parameter: parametersInfo, latestAQ: latestAQInfo, completion: completion)
                } else {
                    completion(AirQualityIntentResponse(code: .failure, userActivity: nil)); return
                }
            }
        }
    }
    
    func handleRequest(targetLocation: CLPlacemark, parameter: Parameter, latestAQ: LatestAQ, completion: @escaping (AirQualityIntentResponse) -> Void) {
        guard let firstResult = latestAQ.results.first else { completion(AirQualityIntentResponse(code: .noData, userActivity: nil)); return }
        
        guard !firstResult.measurements.isEmpty else { completion(AirQualityIntentResponse(code: .noData, userActivity: nil)); return }
        
        var result: [String] = []
        for measurement in firstResult.measurements {
            guard let parameterInfo = parameter.results.filter({ $0.id == measurement.parameter.rawValue }).first else { continue }
            let measurementValue = Foundation.Measurement(value: measurement.value, unit: measurement.unit.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if measurement.unit.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurementValue)
            let localizedString = String.localizedStringWithFormat("%@ of %@", localizedMeasurement, parameterInfo.name)
            result.append(localizedString)
        }
        
        let response = AirQualityIntentResponse.success(targetLocation: targetLocation, airQualityResults: result)
        completion(response)
    }
}
