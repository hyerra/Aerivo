//
//  MapViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/1/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import Mapbox
import AerivoKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.userTrackingMode = .follow
        mapView.styleURL = MGLStyle.outdoorsStyleURL
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        pulleyViewController?.displayMode = .automatic
        pulleyViewController?.drawerBackgroundVisualEffectView = nil
    }
    
    private func positionMapboxAttribution() {
        guard let pulleyVC = pulleyViewController else { return }
        guard pulleyVC.currentDisplayMode == .bottomDrawer else { return }
        let distance = pulleyVC.drawerDistanceFromBottom
        mapView.logoView.translatesAutoresizingMaskIntoConstraints = true
        mapView.attributionButton.translatesAutoresizingMaskIntoConstraints = true
        let distanceFromBottom = distance.distance + distance.bottomSafeArea + 4
        mapView.logoView.frame = CGRect(x: mapView.logoView.frame.minX, y: view.bounds.height - distanceFromBottom, width: mapView.logoView.bounds.width, height: mapView.logoView.bounds.height)
        mapView.attributionButton.frame = CGRect(x: mapView.attributionButton.frame.minX, y: view.bounds.height - distanceFromBottom, width: mapView.attributionButton.bounds.width, height: mapView.attributionButton.bounds.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Pulley primary content controller delegate

extension MapViewController: PulleyPrimaryContentControllerDelegate { }

// MARK: - Map view delegate

extension MapViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        positionMapboxAttribution()
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AOAnnotationView.reuseIdentifier) as? AOAnnotationView ?? AOAnnotationView(reuseIdentifier: AOAnnotationView.reuseIdentifier)
        annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        annotationView.backgroundColor = (pulleyViewController?.drawerContentViewController as? PlacesViewController)?.annotationBackgroundColor
        annotationView.annotationImage.image = (pulleyViewController?.drawerContentViewController as? PlacesViewController)?.annotationImage
        return annotationView
    }
}
