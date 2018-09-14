//
//  MapViewController.swift
//  Aerivo MacOS
//
//  Created by Harish Yerra on 9/8/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Cocoa
import Mapbox

class MapViewController: NSViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.styleURL = MGLStyle.outdoorsStyleURL
        mapView.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

// MARK: - Map view delegate

extension MapViewController: MGLMapViewDelegate {
    
}
