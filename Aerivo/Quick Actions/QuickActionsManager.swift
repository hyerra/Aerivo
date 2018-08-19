//
//  QuickActionsManager.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/11/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import AerivoKit
import UIKit
import CoreData
import Pulley

/// Handles quick actions defined within the app.
final class QuickActionsManager: NSObject {
    
    /// The application's window.
    var window: UIWindow?
    
    /// Creates a quick actions manager with a specified window.
    ///
    /// - Parameter window: The window to use when handling quick actions.
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - Types
    
    enum ShortcutIdentifier: String {
        case search
        case favorite
        
        // MARK: - Initializers
        
        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: ".").last else { return nil }
            self.init(rawValue: last)
        }
        
        // MARK: - Properties
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    /// Generates dynamic shortcut items out of the favorited items in core data.
    ///
    /// - Returns: The generated shortcut items.
    func dynamicShortcutItems() -> [UIApplicationShortcutItem]? {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        guard let favorites = try? DataController.shared.managedObjectContext.fetch(fetchRequest) else { return nil }
        var shortcutItems: [UIApplicationShortcutItem] = []
        for favorite in favorites {
            let icon = UIApplicationShortcutIcon(type: .favorite)
            let shortcutItem = UIApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".favorite", localizedTitle: favorite.name ?? NSLocalizedString("Placemark", comment: "A location on a map."), localizedSubtitle: favorite.genres?.first, icon: icon, userInfo: ["favorite": favorite.objectID.uriRepresentation().absoluteString as NSSecureCoding])
            shortcutItems.append(shortcutItem)
        }
        return shortcutItems
    }
    
    /// Handles the incoming shortcut item.
    ///
    /// - Parameter shortcutItem: The shortcut item to handle.
    /// - Returns: Whether or not it was handled successfully.
    @discardableResult
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortcutType = shortcutItem.type as String? else { return false }
        
        guard let pulleyVC = window?.rootViewController as? PulleyViewController else { return false }
        guard let placesVC = pulleyVC.drawerContentViewController as? PlacesViewController else { return false }
        placesVC.dismiss(animated: true)
        
        switch shortcutType {
        case ShortcutIdentifier.search.type:
            handled = true
            placesVC.searchBar.becomeFirstResponder()
        case ShortcutIdentifier.favorite.type:
            handled = true
            guard let userInfo = shortcutItem.userInfo else { return false }
            guard let favoriteString = userInfo["favorite"] as? String else { return false }
            guard let favoriteURL = URL(string: favoriteString) else { return false }
            guard let favoriteObjectID = DataController.shared.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: favoriteURL) else { return false }
            guard let favorite = DataController.shared.managedObjectContext.object(with: favoriteObjectID) as? Favorite else { return false }
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PlacesDetailViewController.identifier) as? PlacesDetailViewController {
                vc.placemark = favorite
                placesVC.present(vc, animated: true) {
                    placesVC.view.alpha = 0
                    pulleyVC.setDrawerPosition(position: .open, animated: true)
                }
            }
        default:
            break
        }
        
        return handled
    }
}
