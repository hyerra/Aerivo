//
//  SearchResultsTableRowController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/23/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation
import WatchKit

class SearchResultsTableRowController: NSObject {
    static let identifier = "searchResultsRow"
    
    @IBOutlet var iconGroup: WKInterfaceGroup!
    @IBOutlet var icon: WKInterfaceImage!
    @IBOutlet var placeName: WKInterfaceLabel!
    @IBOutlet var address: WKInterfaceLabel!
}
