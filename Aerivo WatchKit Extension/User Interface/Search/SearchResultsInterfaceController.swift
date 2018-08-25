//
//  SearchResultsInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/23/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import MapboxGeocoder
import Foundation

class SearchResultsInterfaceController: WKInterfaceController {
    
    static let identifier = "searchResultsIC"
    
    @IBOutlet var searchResultsTable: WKInterfaceTable!
    @IBOutlet var searchResultsEmptyGroup: WKInterfaceGroup!
    
    var results: [GeocodedPlacemark] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if let placemarks = context as? [GeocodedPlacemark] { self.results = placemarks }
        setTitle(String.localizedStringWithFormat(NSLocalizedString("%d Result(s)", comment: "Shows the number of locations that showed up when a user searched for a location."), results.count))
        reloadSearchResults()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Search Results
    
    private func reloadSearchResults() {
        searchResultsTable.setNumberOfRows(results.count, withRowType: SearchResultsTableRowController.identifier)
        searchResultsEmptyGroup.setHidden(searchResultsTable.numberOfRows != 0)
        
        for rowIndex in 0..<searchResultsTable.numberOfRows {
            let searchResult = results[rowIndex]
            let row = searchResultsTable.rowController(at: rowIndex) as! SearchResultsTableRowController
            row.iconGroup.setBackgroundColor(searchResult.scope.displayColor)
            row.icon.setImageNamed("\(searchResult.imageName ?? "marker")-15")
            row.placeName.setText(searchResult.name)
            row.address.setText((searchResult.addressDictionary?["formattedAddressLines"] as? [String])?.first)
        }
    }
    
    // MARK: - Navigation
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if table == searchResultsTable {
            return results[rowIndex]
        }
        return nil
    }
}
