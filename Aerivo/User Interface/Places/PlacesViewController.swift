//
//  PlacesViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/2/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import Mapbox
import AerivoKit

class PlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var topGripperView: UIView!
    @IBOutlet weak var bottomGripperView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    var previousMapSearchTask: URLSessionDataTask?
    var mapSearchResults: [GeocodedPlacemark] = [] { didSet { placesTableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        pulleyViewController?.feedbackGenerator = UIImpactFeedbackGenerator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        createTableViewBlurEffect()
        createBottomViewBlurEffect()
    }
    
    private func createTableViewBlurEffect() {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        blurEffectView.frame = placesTableView.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        placesTableView.backgroundView = blurEffectView
    }
    
    private func createBottomViewBlurEffect() {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        blurEffectView.frame = bottomView.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        bottomView.insertSubview(blurEffectView, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlacesTableViewCell.reuseIdentifier, for: indexPath) as! PlacesTableViewCell
        let result = mapSearchResults[indexPath.row]
        
        let imageName = result.imageName ?? "marker"
        cell.icon.image = UIImage(named: "\(imageName)-11", in: Bundle(for: GeocodedPlacemark.self), compatibleWith: nil)
            
        cell.placeName.text = result.formattedName
        // TODO: If the wikidata entry is there use that and fall back on the qualified name if it isn't present.
        cell.secondaryDetail.text = result.qualifiedName
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - Pulley drawer delegate

extension PlacesViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264 + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        loadViewIfNeeded()
        placesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSafeArea, right: 0)
        
        if drawer.drawerPosition == .collapsed {
            placesTableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: placesTableView.bounds.width, height: 68 + bottomSafeArea)
        } else {
            placesTableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: placesTableView.bounds.width, height: 68)
        }
                
        placesTableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        if drawer.drawerPosition != .open { searchBar.resignFirstResponder() }
        
        if drawer.currentDisplayMode == .leftSide {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        if drawer.currentDisplayMode == .bottomDrawer {
            topGripperView.alpha = 1
            bottomGripperView.alpha = 0
        } else {
            topGripperView.alpha = 0
            bottomGripperView.alpha = 1
        }
    }
}

// MARK: - Search bar delegate

extension PlacesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        previousMapSearchTask?.cancel()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchMap(for:)), with: searchText, afterDelay: 0.5)
    }
    
    @objc private func searchMap(for query: String) {
        let options = ForwardGeocodeOptions(query: query)
        options.focalLocation = (pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView.userLocation?.location
        options.maximumResultCount = 10
        options.locale = Locale.autoupdatingCurrent
        
        let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
            self.mapSearchResults = placemarks ?? []
        }
        previousMapSearchTask = task
        task.resume()
    }
}
