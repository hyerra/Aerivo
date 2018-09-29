//
//  LocationManager.swift
//  AerivoKit
//
//  Created by Harish Yerra on 9/29/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents a location manager that can be used to monitor the user's location.
public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// The shared location manager.
    public static var shared = LocationManager()
    
    /// The `CLLocationManager` used to get location data.
    public let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        #if os(iOS) || os(watchOS)
        locationManager.requestWhenInUseAuthorization()
        #endif
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        #if os(macOS)
        locationManager.startUpdatingLocation()
        #endif
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationDidChange"), object: location)
    }
    
}
