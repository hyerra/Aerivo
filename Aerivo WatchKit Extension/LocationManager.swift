//
//  LocationManager.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents a location manager that can be used to monitor the user's location.
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// The shared location manager.
    static var shared = LocationManager()
    
    /// The `CLLocationManager` used to get location data.
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationDidChange"), object: location)
    }
    
}
