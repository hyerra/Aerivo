//
//  NearbyTableRowController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import WatchKit

class NearbyTableRowController: NSObject {
    
    static let identifier = "nearbyRow"
    
    @IBOutlet var icon: WKInterfaceImage!
    @IBOutlet var placeName: WKInterfaceLabel!
    @IBOutlet var address: WKInterfaceLabel!
}
