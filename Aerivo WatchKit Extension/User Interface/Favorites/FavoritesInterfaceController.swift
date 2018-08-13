//
//  FavoritesInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import CoreData
import AerivoKit
import Foundation

class FavoritesInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var favoritesTable: WKInterfaceTable!
    @IBOutlet weak var emptyGroup: WKInterfaceGroup!
    
    var favorites: [Favorite] = [] {
        didSet {
            reloadFavoritesTable()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Favorites", comment: "TItle of the screen that shows a user their favorites."))
        emptyGroup.setHidden(true)
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
    
    // MARK: - Table management
    
    func reloadFavoritesTable() {
        favoritesTable.setNumberOfRows(favorites.count, withRowType: FavoritesRowController.identifier)
        
        for rowIndex in 0..<favoritesTable.numberOfRows {
            let favorite = favorites[rowIndex]
            let row = favoritesTable.rowController(at: rowIndex) as! FavoritesRowController
            row.placeName.setText(favorite.name)
            row.address.setText(favorite.formattedAddressLines?.first)
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
        emptyGroup.setHidden(!favorites.isEmpty)
    }
}
