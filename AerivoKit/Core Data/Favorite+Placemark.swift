//
//  Favorite+Placemark.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/30/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import CoreData
import MapboxGeocoder

extension Favorite {
    
    /// Initializes a favorite managed object based on a placemark and inserts it into the specified managed object context.
    ///
    /// - Parameters:
    ///   - placemark: The placemark you wish to favorite.
    ///   - context: The managed object context you wish to save into.
    public convenience init(placemark: GeocodedPlacemark, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.formattedAddressLines = placemark.addressDictionary?["formattedAddressLines"] as? [String]
        self.genres = placemark.genres
        if let latitude = placemark.location?.coordinate.latitude { self.latitude = NSNumber(value: latitude) }
        if let longitude = placemark.location?.coordinate.longitude { self.longitude = NSNumber(value: longitude) }
        self.maki = placemark.imageName
        self.name = placemark.name
        self.qualifiedName = placemark.qualifiedName
        self.wikidataItemIdentifier = placemark.wikidataItemIdentifier
    }
}
