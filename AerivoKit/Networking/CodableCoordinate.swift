//
//  CodableCoordinate.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents a coordinate on Earth.
public struct CodableCoordinate: Codable {
    /// The latitude of the coordinate.
    public var latitude: Double
    /// The longitude of the coordinate.
    public var longitude: Double
}

extension CLLocationCoordinate2D {
    
    /// Initializes a new coordinate based off of a Codable Coordinate.
    ///
    /// - Parameter coordinate: The coordinate that should be used when initializing the Core Location coordinate.
    public init(coordinate: CodableCoordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
