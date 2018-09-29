//
//  AAirQualityTableCellView.swift
//  AirQualityWidget MacOS
//
//  Created by Harish Yerra on 9/28/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Cocoa

class AirQualityTableCellView: NSTableCellView {
    static let identifier = "airQualityRow"
    @IBOutlet weak var parameter: NSTextField!
    @IBOutlet weak var value: NSTextField!
}
