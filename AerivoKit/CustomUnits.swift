//
//  CustomUnits.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/24/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

extension UnitConcentrationMass {
    /// Returns the microgram per cubic meter unit of concentration.
    @NSCopying open static var microgramsPerCubicMeter = UnitConcentrationMass(symbol: "µg/m³", converter: UnitConverterLinear(coefficient: 1000000000))
    /// Returns the milligrams per liter unit of concentration.
    @NSCopying open static var milligramsPerLiter = UnitConcentrationMass(symbol: NSLocalizedString("mg/L", comment: "Milligrams per liter (unit of measurement)"), converter: UnitConverterLinear(coefficient: 1000))
}

/// A unit of measure of turbidity.
open class UnitTurbidity: Unit {
    /// Returns the formazin nephelometric unit of turbidity.
    open static var formazinNephelometricUnit = UnitTurbidity(symbol: NSLocalizedString("FNU", comment: "Formazin nephelometric unit (unit of turbidity)"))
    /// Returns the nephelometric turbidity ratio unit of turbidity.
    open static var nephelometricTurbidityRatioUnit = UnitTurbidity(symbol: NSLocalizedString("NTRU", comment: "Nephelometric turbidity ratio unit (unit of turbidity)"))
    /// Returns the nephelometric turbidity unit of turbidity.
    open static var nephelometricTurbidityUnit = UnitTurbidity(symbol: NSLocalizedString("NTU", comment: "Nephelometric turbidity unit (unit of turbidity)"))
    
    open static let baseUnit = formazinNephelometricUnit
}
