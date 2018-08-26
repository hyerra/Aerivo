//
//  IntentHandler.swift
//  AerivoWatchKitIntents
//
//  Created by Harish Yerra on 8/25/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import AerivoKit
import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is AirQualityIntent:
            return AirQualityIntentHandler()
        default:
            fatalError("Unknown intent.")
        }
    }
    
}
