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
    
    static let identifier = "mapVC"
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Pulley primary content controller delegate

extension MapViewController: PulleyPrimaryContentControllerDelegate {
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        guard let drawer = pulleyViewController, drawer.currentDisplayMode == .bottomDrawer else { return }
        mapView.logoView.alpha = 1.0 - progress
        mapView.attributionButton.alpha = 1.0 - progress
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        positionMapboxAttribution(in: drawer, with: distance)
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        positionMapboxAttribution(in: drawer, with: drawer.drawerDistanceFromBottom.distance)
    }
    
    private func positionMapboxAttribution(in pulleyVC: PulleyViewController, with bottomDistance: CGFloat) {
        mapView.logoView.translatesAutoresizingMaskIntoConstraints = false
        mapView.attributionButton.translatesAutoresizingMaskIntoConstraints = false
        guard pulleyVC.currentDisplayMode == .bottomDrawer else {
            // Set the frame in case the view was rotated.
            mapView.logoView.frame = CGRect(x: mapView.directionalLayoutMargins.leading, y: mapView.bounds.height - mapView.logoView.bounds.height - 8, width: mapView.logoView.bounds.width, height: mapView.logoView.bounds.height)
            mapView.attributionButton.frame = CGRect(x: mapView.bounds.maxX - mapView.directionalLayoutMargins.trailing - mapView.attributionButton.bounds.width, y: mapView.bounds.height - mapView.attributionButton.bounds.height - 8, width: mapView.attributionButton.bounds.width, height: mapView.attributionButton.bounds.height)
            return
        }
        
        mapView.logoView.frame = CGRect(x: mapView.directionalLayoutMargins.leading, y: mapView.bounds.height - bottomDistance - mapView.logoView.bounds.height - 8, width: mapView.logoView.bounds.width, height: mapView.logoView.bounds.height)
        mapView.attributionButton.frame = CGRect(x: mapView.bounds.maxX - mapView.directionalLayoutMargins.trailing - mapView.attributionButton.bounds.width, y: mapView.bounds.height - bottomDistance - mapView.attributionButton.bounds.height - 8, width: mapView.attributionButton.bounds.width, height: mapView.attributionButton.bounds.height)
    }
}

// MARK: - Map view delegate

extension MapViewController: MGLMapViewDelegate {
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
