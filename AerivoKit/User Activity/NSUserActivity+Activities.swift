//
//  NSUserActivity+Activities.swift
//  AerivoKit
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

extension NSUserActivity {
    
    public struct ActivityKeys {
        public static let searchText = "search_text"
    }
        
    /// A user activity that represents searching for a place in Aerivo.
    public static var searchActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: "com.harishyerra.Aerivo.search")
        
        // User activites should be as rich as possible, with icons and localized strings for appropiate content attributes.
        userActivity.title = NSLocalizedString("Search for a location", comment: "Search for a location on the map activity title.")
        userActivity.requiredUserInfoKeys = []
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = true
            userActivity.suggestedInvocationPhrase = NSLocalizedString("Find environmental quality information.", comment: "Voice shortcut suggested phrase for finding air and water quality info.")
        }
        
        return userActivity
    }
    
    public static var viewPlaceActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: "com.harishyerra.Aerivo.viewPlace")
        
        // User activites should be as rich as possible, with icons and localized strings for appropiate content attributes.
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForHandoff = true
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = true
        }
        
        return userActivity
    }
}
