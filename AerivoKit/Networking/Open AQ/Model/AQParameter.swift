//
//  AQParameter.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a simple listing of parameters within Open AQ.
public struct Parameter: OpenAQResponse {
    /// The meta information containing name, licensing info, etc.
    public var meta: Meta
    /// The result data that provides the contents of the fetch.
    public var results: [Result]
    
    /// Represents the result that contains the contents of the parameters.
    public struct Result: Codable {
        /// The id of the parameter.
        public var id: String
        /// The name of the parameter.
        public var name: String
        /// The description pertaining to the parameter.
        public var description: String
        /// The parameter's prefered unit.
        public var preferredUnit: AirQualityUnitCode
        
        public var information: String? {
            switch id {
            case "bc": return NSLocalizedString("Black Carbon: Sooty black material emitted from gas and diesel engines, coal-fired power plants, and other sources that burn fossil fuel.", comment: "Description of the harmful effects of black carbon.")
            case "co": return NSLocalizedString("Carbon Monoxide: A gas that has no odor or color. But it is very dangerous. It can cause sudden illness and death. Anywhere between 0-2 ppm is OK for outside conditions with 2 ppm being on the high end; however, anything more and you should report it.", comment: "Description of the harmful effects of carbon monoxide.")
            case "no2": return NSLocalizedString("Nitrogen Dioxide: Leads to acid rain, hazy air, and nutrient pollution in coastal waters. Forms from emissions from cars, trucks and buses, power plants, and off-road equipment.", comment: "Description of the harmful effects of nitrogen dioxide.")
            case "o3": return NSLocalizedString("Ozone: Contributes to what we typically experience as haze (smog), which still occurs most frequently in the summertime, but can occur throughout the year in some southern and mountain regions. When inhaled, it reacts chemically with many biological molecules in the respiratory tract, leading to a number of adverse health effects.", comment: "Description of the harmful effects of ozone.")
            case "pm10": return NSLocalizedString("Particulate Matter (<10 micrometers): Particles in the air like organic dust, airborne bacteria, and construction dust that are less than 10 micrometers in diameter. These particles can be drawn deep into the lungs.", comment: "Description of the harmful effects of particulate matter (<10 micrometers).")
            case "pm25": return NSLocalizedString("Particulate Matter (<2.5 micrometers): Particles in the air like organic dust, airborne bacteria, and construction dust that are less than 2.5 micrometers in diameter. These particles can be drawn deep into the lungs.", comment: "Description of the harmful effects of particulate matter (<2.5 micrometers).")
            case "so2": return NSLocalizedString("Sulfur Dioxide: An invisible gas that has a nasty, sharp smell. It reacts easily with other substances to form harmful compounds, such as sulfuric acid, sulfurous acid and sulfate particles. Large amounts can lead to acid rain.", comment: "Description of the harmful effects of sulfur dioxide.")
            default: return nil
            }
        }
    }
    
}

// MARK: - Equatable

extension Parameter.Result: Equatable {
    public static func == (lhs: Parameter.Result, rhs: Parameter.Result) -> Bool {
        return lhs.id == rhs.id
    }
}
