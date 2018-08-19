//
//  Placemark.swift
//  AerivoKit
//
//  Created by Harish Yerra on 8/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import AerivoKit
import MapboxGeocoder

/// Represents a placemark that represents a location on a map.
protocol Placemark {
    /// The address lines of the location.
    var addressLines: [String]? { get }
    /// An array of keywords that describe the genre of the point of interest represented by the placemark.
    var genres: [String]? { get }
    /// The latitude of the location.
    var latitude: NSNumber? { get }
    /// The longitude of the location.
    var longitude: NSNumber? { get }
    /// The icon name of the location.
    var maki: String? { get }
    /// The display name of the location.
    var displayName: String? { get }
    /// The full name and address of the location.
    var qualifiedName: String? { get }
    /// The scope offers a general indication of the size or importance of the feature represented by the placemark – in other words, how local the feature is.
    var relativeScope: MBPlacemarkScope { get }
    /// The Wikidata item contains structured information about the feature represented by the placemark. It also links to corresponding entries in various free content or open data resources, including Wikipedia, Wikimedia Commons, Wikivoyage, and Freebase.
    var wikidataItemIdentifier: String? { get }
}

extension Favorite: Placemark {
    var addressLines: [String]? {
        return formattedAddressLines
    }
    
    var displayName: String? {
        return name
    }
    
    var relativeScope: MBPlacemarkScope {
        return MBPlacemarkScope(rawValue: UInt(scope))
    }
}

extension GeocodedPlacemark: Placemark {
    var addressLines: [String]? {
        return addressDictionary?["formattedAddressLines"] as? [String]
    }
    
    var latitude: NSNumber? {
        guard let latitude = location?.coordinate.latitude else { return nil }
        return NSNumber(value: latitude)
    }
    
    var longitude: NSNumber? {
        guard let longitude = location?.coordinate.longitude else { return nil }
        return NSNumber(value: longitude)
    }
    
    var maki: String? {
        return imageName
    }
    
    var displayName: String? {
        return formattedName
    }
    
    var relativeScope: MBPlacemarkScope {
        return scope
    }
}
