//
//  RecommendationInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import MapboxGeocoder
import AerivoKit
import Foundation

class RecommendationInterfaceController: WKInterfaceController {
    
    static let identifier = "recommendationIC"
    
    @IBOutlet var nearbyLabel: WKInterfaceLabel!
    @IBOutlet var nearbyTable: WKInterfaceTable!
    @IBOutlet var nearbyEmptyGroup: WKInterfaceGroup!
    
    var nearbyResults: [GeocodedPlacemark] = [] {
        didSet {
            reloadNearbyTable()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo")
        NotificationCenter.default.addObserver(self, selector: #selector(loadNearbyResults), name: NSNotification.Name(rawValue: "LocationDidChange"), object: nil)
        loadNearbyResults()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        // This method is called when watch view controller is visible to user
        LocationManager.shared.locationManager.startUpdatingLocation()
        super.didAppear()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        LocationManager.shared.locationManager.stopUpdatingLocation()
        super.didDeactivate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Nearby
    
    @objc
    private func loadNearbyResults() {
        let location = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        
        let options = ReverseGeocodeOptions(location: location)
        options.maximumResultCount = 5
        options.allowedScopes = .landmark
        options.locale = Locale.autoupdatingCurrent
        
        Geocoder.shared.geocode(options) { placemarks, attribution, error in
            self.nearbyResults = placemarks ?? []
        }
    }
    
    private func reloadNearbyTable() {
        nearbyTable.setNumberOfRows(nearbyResults.count, withRowType: NearbyTableRowController.identifier)
        nearbyLabel.setHidden(nearbyTable.numberOfRows == 0)
        nearbyEmptyGroup.setHidden(nearbyTable.numberOfRows != 0)
        
        for rowIndex in 0..<nearbyTable.numberOfRows {
            let result = nearbyResults[rowIndex]
            let row = nearbyTable.rowController(at: rowIndex) as! NearbyTableRowController
            row.iconGroup.setBackgroundColor(result.scope.displayColor)
            row.icon.setImageNamed("\(result.imageName ?? "marker")-15")
            row.placeName.setText(result.formattedName)
            row.address.setText((result.addressDictionary?["formattedAddressLines"] as? [String])?.first)
        }
    }
    
    // MARK: - Navigation
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if table == nearbyTable {
            return nearbyResults[rowIndex]
        }
        return nil
    }
    
}
