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
        NotificationCenter.default.addObserver(self, selector: #selector(setLocationImage), name: NSNotification.Name(rawValue: "LocationDidChange"), object: nil)
        setLocationImage()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        // This method is called when watch view controller is visible to user
        LocationManager.shared.locationManager.startUpdatingLocation()
        super.didAppear()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        LocationManager.shared.locationManager.stopUpdatingLocation()
        super.didDeactivate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        imageLoadingTask?.cancel()
    }
    
    // MARK: - Location Image
    
    @objc
    private func setLocationImage() {
        let location = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
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
