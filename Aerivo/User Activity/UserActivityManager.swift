//
//  UserActivityManager.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import UIKit
import MapboxGeocoder
import CoreLocation
import Pulley

/// Handles user activities defined within the app.
class UserActivityManager: NSObject {
    
    /// The application's window.
    var window: UIWindow?
    
    /// Creates a user activity manager with a specified window.
    ///
    /// - Parameter window: The window to use when handling quick actions.
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// Handles the incoming user activity.
    ///
    /// - Parameter userActivity: The user activity to handle.
    /// - Returns: Whether or not it was handled successfully.
    @discardableResult
    func handle(userActivity: NSUserActivity) -> Bool {
        var handled = false
        
        guard let pulleyVC = window?.rootViewController as? PulleyViewController else { return false }
        guard let placesVC = pulleyVC.drawerContentViewController as? PlacesViewController else { return false }
        placesVC.dismiss(animated: true)
        
        switch userActivity.activityType {
        case NSUserActivity.searchActivity.activityType:
            handled = true
            if let searchText = userActivity.userInfo?[NSUserActivity.ActivityKeys.searchText] {
                placesVC.searchBar.text = searchText as? String
                placesVC.searchBar.becomeFirstResponder()
            }
        case NSUserActivity.viewPlaceActivity.activityType:
            guard let location = userActivity.userInfo?[NSUserActivity.ActivityKeys.location] as? [String: Any] else { break }
            guard let latitude = location["latitude"] as? Double else { break }
            guard let longitude = location["longitude"] as? Double else { break }
            handled = true
            let coordinate = CLLocation(latitude: latitude, longitude: longitude)
            let options = ReverseGeocodeOptions(location: coordinate)
            options.maximumResultCount = 1
            options.locale = Locale.autoupdatingCurrent
            
            let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
                guard let placemark = placemarks?.first else { return }
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PlacesDetailViewController.identifier) as? PlacesDetailViewController {
                    vc.placemark = placemark
                    placesVC.present(vc, animated: true) {
                        placesVC.view.alpha = 0
                        pulleyVC.setDrawerPosition(position: .open, animated: true)
                    }
                }
            }
            task.resume()
        default:
            break
        }
        
        return handled
    }
    
}
