//
//  QuickActionsManager.swift
//  Aerivo
//
//  Created by Harish Yerra on 8/11/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
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
    
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        switch shortCutType {
        case ShortcutIdentifier.search.type:
            handled = true
            guard let pulleyVC = window?.rootViewController as? PulleyViewController else { return false }
            guard let placesVC = pulleyVC.drawerContentViewController as? PlacesViewController else { return false }
            placesVC.searchBar.becomeFirstResponder()
        default:
            break
        }
        
        return handled
    }
}
