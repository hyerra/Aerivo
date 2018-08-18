//
//  PlaceDetailInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import Foundation

class PlaceDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "placeDetailIC"
    
    @IBOutlet var location: WKInterfaceLabel!
    
    @IBOutlet var airQualityHeading: WKInterfaceLabel!
    @IBOutlet var airQualityTable: WKInterfaceTable!
    
    @IBOutlet var waterQualityHeading: WKInterfaceLabel!
    @IBOutlet var waterQualityTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Back", comment: "Allows the user to go back to the previous screen."))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
        
}
