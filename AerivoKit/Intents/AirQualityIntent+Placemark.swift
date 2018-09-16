//
//  AirQualityIntent+Placemark.swift
//  AerivoKit
//
//  Created by Harish Yerra on 8/28/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import AerivoKit
import Intents

@available(iOS 12.0, watchOS 5.0, *)
extension AirQualityIntent {
    
    /// Initalizes a new intent based off of a placemark.
    ///
    /// - Parameter placemark: The placemark to base the intent off of.
    convenience init(placemark: Placemark) {
        self.init()
        if let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            self.targetLocation = CLPlacemark(location: location, name: placemark.displayName, postalAddress: nil)
        }
        
        if let name = placemark.displayName {
            self.suggestedInvocationPhrase = NSLocalizedString("Air quality", comment: "A Siri suggested invocation phrase that is a short command to find the air quality at a specific location.")
        }
    }
}

@available(iOS 12.0, watchOS 5.0, *)
extension INInteraction {
    
    /// Initializes a new interaction based off of the air quality intent and a response.
    ///
    /// - Parameters:
    ///   - intent: The intent from which the interaction will be created from.
    ///   - response: The response object that is provided in response to the intent.
    convenience init(airQualityIntent intent: AirQualityIntent, response: INIntentResponse?) {
        self.init(intent: intent, response: response)
        
        if let location = intent.targetLocation, let latitude = location.location?.coordinate.latitude, let longitude = location.location?.coordinate.longitude {
            self.identifier = "latitude:\(latitude),longitude:\(longitude)"
        }
    }
}
