//
//  RecommendationInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import MapboxGeocoder
import CoreLocation
import Foundation

class RecommendationInterfaceController: WKInterfaceController {
    
    static let identifier = "recommendationIC"
    
    @IBOutlet var nearbyLabel: WKInterfaceLabel!
    @IBOutlet var nearbyTable: WKInterfaceTable!
    
    var nearbyResults: [GeocodedPlacemark] = [] {
        didSet {
            reloadNearbyTable()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo")
        loadNearbyResults()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Nearby
    
    func loadNearbyResults() {
        let location = CLLocationManager().location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        
        let options = ReverseGeocodeOptions(location: location)
        options.maximumResultCount = 5
        options.allowedScopes = .landmark
        options.locale = Locale.autoupdatingCurrent
        
        let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
            self.nearbyResults = placemarks ?? []
        }
        
        task.resume()
    }
    
    func reloadNearbyTable() {
        nearbyTable.setNumberOfRows(nearbyResults.count, withRowType: NearbyTableRowController.identifier)
        
        nearbyLabel.setHidden(nearbyTable.numberOfRows == 0)
        
        for rowIndex in 0..<nearbyTable.numberOfRows {
            let result = nearbyResults[rowIndex]
            let row = nearbyTable.rowController(at: rowIndex) as! NearbyTableRowController
            //row.icon.setImage(UIImage(named: "\(result.imageName ?? "marker")-11", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: nil))
            row.placeName.setText(result.formattedName)
            row.address.setText((result.addressDictionary?["formattedAddressLines"] as? [String])?.first)
        }
    }
    
}
