//
//  IntentHandler.swift
//  AerivoIntents
//
//  Created by Harish Yerra on 8/11/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Intents
import AerivoKit

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        guard #available(iOSApplicationExtension 12.0, *) else { return nil }
        switch intent {
        case is AirQualityIntent:
            return AirQualityIntentHandler()
        default:
            return nil
        }
    }
}
