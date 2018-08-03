//
//  PlacesViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/2/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import Mapbox
import Pulley
import AerivoKit
import CoreData
import MapboxGeocoder

class PlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let identifier = "placesVC"
    
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var headerWasSized = false
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topGripperView: UIView!
    @IBOutlet weak var bottomGripperView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    var previousMapSearchTask: URLSessionDataTask?
    
    var shouldShowDefaultResults = true { didSet { placesTableView.reloadData() } }
    var defaultResults: [GeocodedPlacemark] = []
    var mapSearchResults: [GeocodedPlacemark] = [] { didSet { placesTableView.reloadData() } }
    
    var annotationBackgroundColor: UIColor?
    var annotationImage: UIImage?
    
    var favorites: [Favorite] = [] {
        didSet {
            placesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        searchBar.delegate = self
        generateDefaultResults()
        fetchFavorites()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFavorites), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        pulleyViewController?.feedbackGenerator = UIImpactFeedbackGenerator()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        createViewBlurEffect()
    }
    
    private func createViewBlurEffect() {
        if let blurEffectView = view.subviews.first as? UIVisualEffectView { blurEffectView.frame = view.bounds; return }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        blurEffectView.frame = view.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        view.insertSubview(blurEffectView, at: 0)
    }
    
    @objc private func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        do {
            let favorites = try DataController.shared.managedObjectContext.fetch(fetchRequest)
            self.favorites = favorites
        } catch let error {
            #if DEBUG
            print(error)
            #endif
        }
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
        let resultCount = !shouldShowDefaultResults ? mapSearchResults.count : defaultResults.count
        let favoriteCount = 1
        return resultCount + favoriteCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shouldShowResultCell = !shouldShowDefaultResults ? mapSearchResults.indices.contains(indexPath.row) : defaultResults.indices.contains(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: shouldShowResultCell ? PlacesTableViewCell.reuseIdentifier : FavoritesTableViewCell.reuseIdentifier, for: indexPath)
        
        if shouldShowResultCell {
            let cell = cell as! PlacesTableViewCell
            let result = !shouldShowDefaultResults ? mapSearchResults[indexPath.row] : defaultResults[indexPath.row]
            
            cell.placemark = result
            
            let imageName = result.imageName ?? "marker"
            cell.icon.image = UIImage(named: "\(imageName)-11", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: nil)
            
            cell.placeName.text = result.formattedName
            cell.secondaryDetail.text = (result.addressDictionary?["formattedAddressLines"] as? [String])?.joined(separator: NSLocalizedString(", ", comment: "The seperator between the components of an address."))
            cell.iconBackgroundView.backgroundColor = result.scope.displayColor
        } else {
            let cell = cell as! FavoritesTableViewCell
            cell.count.text = String.localizedStringWithFormat(NSLocalizedString("%d favorite(s)", comment: "Shows the number of favorites a user has."), favorites.count)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if pulleyViewController?.drawerPosition == .open { pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true) }
        
        guard let mapView = (pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView else { return }
        
        mapView.removeAnnotations(mapView.annotations ?? [])
        
        if let placemark = (tableView.cellForRow(at: indexPath) as? PlacesTableViewCell)?.placemark, let coordinate = placemark.location?.coordinate {
            annotationBackgroundColor = placemark.scope.displayColor
            annotationImage = UIImage(named: "\(placemark.imageName ?? "marker")-15", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: nil)
            
            let pointAnnotation = MGLPointAnnotation()
            pointAnnotation.coordinate = coordinate
            pointAnnotation.title = placemark.formattedName
            pointAnnotation.subtitle = placemark.genres?.first
            mapView.addAnnotation(pointAnnotation)
            
            let camera = MGLMapCamera()
            camera.centerCoordinate = coordinate
            camera.altitude = 8000
            mapView.fly(to: camera) {
                mapView.setCenter(coordinate, animated: true)
            }
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: PlacesDetailViewController.identifier) as? PlacesDetailViewController {
            vc.placemark = mapSearchResults[indexPath.row]
            present(vc, animated: true) {
                self.view.alpha = 0
            }
        }
    }
}

// MARK: - Pulley drawer delegate

extension PlacesViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let presentedVC = presentedViewController as? PulleyDrawerViewControllerDelegate {
            if let height = presentedVC.collapsedDrawerHeight?(bottomSafeArea: bottomSafeArea) {
                return height
            }
        }
        
        view.layoutIfNeeded()
        return headerView.bounds.height - headerSpacingConstraint.constant + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let presentedVC = presentedViewController as? PulleyDrawerViewControllerDelegate {
            if let height = presentedVC.partialRevealDrawerHeight?(bottomSafeArea: bottomSafeArea) {
                return height
            }
        }
        
        return 264 + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if let presentedVC = presentedViewController as? PulleyDrawerViewControllerDelegate { presentedVC.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: bottomSafeArea) }
        loadViewIfNeeded()
        placesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSafeArea, right: 0)
        
        if drawer.drawerPosition == .collapsed {
            headerSpacingConstraint.constant = bottomSafeArea
        } else {
            headerSpacingConstraint.constant = 0
        }
                
        placesTableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        if drawer.drawerPosition != .open { searchBar.text = nil; searchBar.resignFirstResponder() }
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        if let presentedVC = presentedViewController as? PulleyDrawerViewControllerDelegate { presentedVC.drawerDisplayModeDidChange?(drawer: drawer) }
        if drawer.currentDisplayMode == .bottomDrawer {
            topGripperView.alpha = 1
            bottomGripperView.alpha = 0
        } else {
            topGripperView.alpha = 0
            bottomGripperView.alpha = 1
        }
        
        if drawer.currentDisplayMode == .leftSide {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
    }
}

// MARK: - Search bar delegate

extension PlacesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { shouldShowDefaultResults = true; return }
        shouldShowDefaultResults = false
        previousMapSearchTask?.cancel()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchMap(for:)), with: searchText, afterDelay: 0.5)
    }
    
    @objc private func generateDefaultResults() {
        let location = (pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView.userLocation?.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        let options = ReverseGeocodeOptions(location: location)
        options.maximumResultCount = 5
        options.allowedScopes = .landmark
        options.locale = Locale.autoupdatingCurrent
        
        let task = Geocoder.shared.geocode(options) { placemarks, attribution, error in
            self.defaultResults = placemarks ?? []
            if self.shouldShowDefaultResults { self.placesTableView.reloadData() }
        }
        task.resume()
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
