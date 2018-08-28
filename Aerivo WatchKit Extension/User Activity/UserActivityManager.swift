//
//  UserActivityManager.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/25/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import AerivoKit
import MapboxGeocoder

/// Handles user activities defined within the app.
class UserActivityManager: NSObject {
    
    /// The application's window.
    var visibleInterfaceController: WKInterfaceController?
    
    /// Creates a user activity manager with a specified window.
    ///
    /// - Parameter visibleInterfaceController: The visible interface controller to use when handling quick actions.
    init(visibleInterfaceController: WKInterfaceController?) {
        self.visibleInterfaceController = visibleInterfaceController
    }
    
    /// Handles the incoming air quality intent.
    ///
    /// - Parameter airQualityIntent: The intent to handle.
    @available(watchOS 5.0, *)
    func handle(airQualityIntent: AirQualityIntent) {
        guard let location = airQualityIntent.targetLocation?.location else { return }
        let options = ReverseGeocodeOptions(location: location)
        options.locale = Locale.autoupdatingCurrent
        
        let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
            guard let placemark = placemarks?.first else { return }
            WKExtension.shared().rootInterfaceController?.pushController(withName: PlaceDetailInterfaceController.identifier, context: placemark)
        }
        task.resume()
    }
    
    /// Handles the incoming user activity.
    ///
    /// - Parameter userActivity: The user activity to handle.
    func handle(userActivity: NSUserActivity) {
        WKExtension.shared().rootInterfaceController?.popToRootController()
        switch userActivity.activityType {
        case NSUserActivity.searchActivity.activityType:
            if let searchText = userActivity.userInfo?[NSUserActivity.ActivityKeys.searchText] as? String {
                let options = ForwardGeocodeOptions(query: searchText)
                options.focalLocation = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
                options.maximumResultCount = 10
                options.autocompletesQuery = false
                options.locale = Locale.autoupdatingCurrent
                
                let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
                   WKExtension.shared().rootInterfaceController?.pushController(withName: SearchResultsInterfaceController.identifier, context: placemarks)
                }
                task.resume()
            } else {
                WKExtension.shared().rootInterfaceController?.pushController(withName: SearchInterfaceController.identifier, context: nil)
            }
        case NSUserActivity.viewPlaceActivity.activityType:
            guard let location = userActivity.userInfo?[NSUserActivity.ActivityKeys.location] as? [String: Any] else { break }
            guard let latitude = location["latitude"] as? Double else { break }
            guard let longitude = location["longitude"] as? Double else { break }
            let coordinate = CLLocation(latitude: latitude, longitude: longitude)
            let options = ReverseGeocodeOptions(location: coordinate)
            options.locale = Locale.autoupdatingCurrent
            
            let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
                guard let placemark = placemarks?.first else { return }
                WKExtension.shared().rootInterfaceController?.pushController(withName: PlaceDetailInterfaceController.identifier, context: placemark)
            }
            task.resume()
        default:
            break
        }
    }
    
}
