//
//  FavoritesTableRowController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import WatchKit

class FavoritesTableRowController: NSObject {
    static let identifier = "favoritesRow"
    
    @IBOutlet var icon: WKInterfaceImage!
    @IBOutlet var placeName: WKInterfaceLabel!
    @IBOutlet var address: WKInterfaceLabel!
}
