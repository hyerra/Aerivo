//
//  LocationInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/15/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import Foundation
import MapboxStatic

class LocationInterfaceController: WKInterfaceController {
    
    static let identifier = "locationIC"
    
    @IBOutlet var locationInterfaceImage: WKInterfaceImage!
    
    var imageLoadingTask: URLSessionDataTask?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Location", comment: "Title for a screen that shows the users location and related info."))
        setLocationImage()
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
        imageLoadingTask?.cancel()
    }
    
    // MARK: - Location Image
    
    private func setLocationImage() {
        let location = CLLocationManager().location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        let camera = SnapshotCamera(lookingAtCenter: location.coordinate, zoomLevel: 12)
        let mapSize = CGSize(width: WKInterfaceDevice.current().screenBounds.width, height: WKInterfaceDevice.current().screenBounds.height * 0.75)
        let options = SnapshotOptions(styleURL: URL(string: "mapbox://styles/mapbox/outdoors-v9")!, camera: camera, size: mapSize)
        let snapshot = Snapshot(options: options)
        imageLoadingTask = snapshot.image { [weak self] image, error in
            self?.locationInterfaceImage.setImage(image)
        }
        imageLoadingTask?.resume()
    }
    
}
