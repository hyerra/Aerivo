//
//  UserActivityManager.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import UIKit
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
        default:
            break
        }
        
        return handled
    }
    
}
