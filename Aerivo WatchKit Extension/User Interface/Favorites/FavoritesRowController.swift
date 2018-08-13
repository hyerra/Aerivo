//
//  FavoritesRowController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/13/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import WatchKit

class FavoritesRowController: NSObject {
    static let identifier = "favoritesRow"
    
    @IBOutlet weak var placeName: WKInterfaceLabel!
    @IBOutlet weak var address: WKInterfaceLabel!
}
