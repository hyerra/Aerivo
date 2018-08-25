//
//  SearchInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import CoreData
import AerivoKit
import MapboxGeocoder
import Foundation

class SearchInterfaceController: WKInterfaceController {
    
    static let identifier = "searchIC"
    
    @IBOutlet var favoritesLabel: WKInterfaceLabel!
    @IBOutlet var favoritesTable: WKInterfaceTable!
    @IBOutlet var favoritesEmptyGroup: WKInterfaceGroup!
    
    var favorites: [Favorite] = [] {
        didSet {
            reloadFavoritesTable()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Search", comment: "TItle of the screen that allows a user to search for locations."))
        fetchFavorites()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFavorites), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func search() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { results in
            guard let query = results?.first as? String else { return }
            let options = ForwardGeocodeOptions(query: query)
            options.focalLocation = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
            options.maximumResultCount = 10
            options.autocompletesQuery = false
            options.locale = Locale.autoupdatingCurrent
            
            let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
                self.pushController(withName: SearchResultsInterfaceController.identifier, context: placemarks)
            }
            task.resume()
        }
    }
    
    // MARK: - Favorites
    
    @objc private func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        do {
            favorites = try DataController.shared.managedObjectContext.fetch(fetchRequest)
        } catch let error {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    private func reloadFavoritesTable() {
        favoritesTable.setNumberOfRows(favorites.count, withRowType: FavoritesTableRowController.identifier)
        favoritesLabel.setHidden(favoritesTable.numberOfRows == 0)
        favoritesEmptyGroup.setHidden(favoritesTable.numberOfRows != 0)
        
        for rowIndex in 0..<favoritesTable.numberOfRows {
            let favorite = favorites[rowIndex]
            let row = favoritesTable.rowController(at: rowIndex) as! FavoritesTableRowController
            row.iconGroup.setBackgroundColor(favorite.relativeScope.displayColor)
            row.icon.setImageNamed("\(favorite.maki ?? "marker")-15")
            row.placeName.setText(favorite.name)
            row.address.setText(favorite.formattedAddressLines?.first)
        }
    }
    
    // MARK: - Navigation
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if table == favoritesTable {
            return favorites[rowIndex]
        }
        return nil
    }
}
