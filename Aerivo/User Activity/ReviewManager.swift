//
//  ReviewManager.swift
//  Aerivo
//
//  Created by Harish Yerra on 2/2/19.
//  Copyright © 2019 Harish Yerra. All rights reserved.
//

import StoreKit

/// Manages requesting reviews for the App Store.
class ReviewManager: NSObject {
    
    /// A type of event that can be monitered to determine if it is appropriate to request a review.
    ///
    /// - locationViewed: A location was recently viewed.
    enum ReviewEvent: String {
        case locationViewed = "locationViewedEvents"
    }
    
    /// Requsts for a review in the App Store given certain conditions are met.
    ///
    /// - Parameter event: The event that was triggered that merits a potential request for a review.
    class func requestReview(for event: ReviewEvent) {
        switch event {
        case .locationViewed:
            let numberOfLocationViewedEvents = UserDefaults.standard.integer(forKey: ReviewEvent.locationViewed.rawValue)
            if numberOfLocationViewedEvents > Int.random(in: 10...20) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(0, forKey: ReviewEvent.locationViewed.rawValue)
            }
            UserDefaults.standard.set(numberOfLocationViewedEvents + 1, forKey: ReviewEvent.locationViewed.rawValue)
        }
    }
    
}
