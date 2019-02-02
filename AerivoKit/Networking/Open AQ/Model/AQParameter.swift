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
        
        public var localizedName: String? {
            switch id {
            case "bc": return NSLocalizedString("BC", comment: "The abbreviation for Black Carbon.")
            case "co": return NSLocalizedString("CO", comment: "The abbreviation for Carbon Monoxide.")
            case "no2": return NSLocalizedString("NO2", comment: "The abbreviation for Nitrogen Dioxide.")
            case "o3": return NSLocalizedString("O3", comment: "The abbreviation for Ozone.")
            case "pm10": return NSLocalizedString("PM10", comment: "The abbreviation for Particulate matter less than 10 micrometers in diameter.")
            case "pm25": return NSLocalizedString("PM2.5", comment: "The abbreviation for Particulate matter less than 2.5 micrometers in diameter.")
            case "so2": return NSLocalizedString("SO2", comment: "The abbreviation for Sulfur Dioxide")
            default: return nil
            }
        }
        
        public var information: String? {
            switch id {
            case "bc": return NSLocalizedString("Black Carbon: Sooty black material emitted sources that burn fossil fuel.", comment: "Description of the harmful effects of black carbon.")
            case "co": return NSLocalizedString("Carbon Monoxide: A gas that has no odor or color, but can cause illness and death.", comment: "Description of the harmful effects of carbon monoxide.")
            case "no2": return NSLocalizedString("Nitrogen Dioxide: Leads to acid rain, hazy air, and nutrient pollution in coastal waters. Forms from emissions from cars, trucks and buses, power plants, and off-road equipment.", comment: "Description of the harmful effects of nitrogen dioxide.")
            case "o3": return NSLocalizedString("Ozone: Contributes to haze (smog) and chemically reacts with many biological molecules in the respiratory tract.", comment: "Description of the harmful effects of ozone.")
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
