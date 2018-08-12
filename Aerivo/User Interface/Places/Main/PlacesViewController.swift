//
//  PlacesViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/2/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
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
        
    var previousMapSearchTask: URLSessionDataTask?
    
    var shouldShowDefaultResults = true { didSet { placesTableView.reloadData() } }
    var defaultResults: [GeocodedPlacemark] = []
    var mapSearchResults: [GeocodedPlacemark] = [] { didSet { placesTableView.reloadData() } }
    
    lazy var fetchedResultsController = try? FavoriteFetchedResultsController(managedObjectContext: DataController.shared.managedObjectContext, tableView: placesTableView)
    
    var isShowingFavorites = false {
        didSet {
            DispatchQueue.main.async {
                self.placesTableView.reloadData()
                self.fetchedResultsController?.shouldUpdateTableView = self.isShowingFavorites
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        searchBar.delegate = self
        setupAccessibility()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavorites), name: .NSManagedObjectContextDidSave, object: nil)
        userActivity = NSUserActivity.searchActivity
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        isShowingFavorites = false
        pulleyViewController?.feedbackGenerator = UIImpactFeedbackGenerator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func refreshFavorites() {
        DispatchQueue.main.async {
            self.placesTableView.reloadData()
        }
    }
    
    // MARK: - User Activity
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        let userInfo: [String: Any] =  [NSUserActivity.ActivityKeys.searchText: searchBar.text ?? ""]
        activity.addUserInfoEntries(from: userInfo)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibility() {
        accessibilityViewIsModal = true
        topGripperView.accessibilityCustomActions = [UIAccessibilityCustomAction(name: NSLocalizedString("Expand", comment: "Action for expanding the card overlay screen."), target: self, selector: #selector(expand)), UIAccessibilityCustomAction(name: NSLocalizedString("Collapse", comment: "Action for collapsing the card overlay screen."), target: self, selector: #selector(collapse))]
        bottomGripperView.accessibilityCustomActions = [UIAccessibilityCustomAction(name: NSLocalizedString("Expand", comment: "Action for expanding the card overlay screen."), target: self, selector: #selector(expand)), UIAccessibilityCustomAction(name: NSLocalizedString("Collapse", comment: "Action for collapsing the card overlay screen."), target: self, selector: #selector(collapse))]
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isShowingFavorites {
            let resultCount = !shouldShowDefaultResults ? mapSearchResults.count : defaultResults.count
            let favoriteCount = 1
            return resultCount + favoriteCount
        } else {
            guard let section = fetchedResultsController?.sections?[section] else { return 0 }
            return section.numberOfObjects
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isShowingFavorites {
            let shouldShowResultCell = !shouldShowDefaultResults ? mapSearchResults.indices.contains(indexPath.row) : defaultResults.indices.contains(indexPath.row)
            let cell = tableView.dequeueReusableCell(withIdentifier: shouldShowResultCell ? PlacesTableViewCell.reuseIdentifier : FavoritesTableViewCell.reuseIdentifier, for: indexPath)
            
            if shouldShowResultCell {
                let cell = cell as! PlacesTableViewCell
                let result = !shouldShowDefaultResults ? mapSearchResults[indexPath.row] : defaultResults[indexPath.row]
                
                cell.icon.image = UIImage(named: "\(result.imageName ?? "marker")-11", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: nil)
                
                cell.placeName.text = result.formattedName
                cell.secondaryDetail.text = (result.addressDictionary?["formattedAddressLines"] as? [String])?.first
                cell.iconBackgroundView.backgroundColor = result.scope.displayColor
            } else {
                let cell = cell as! FavoritesTableViewCell
                cell.count.text = String.localizedStringWithFormat(NSLocalizedString("%d favorite(s)", comment: "Shows the number of favorites a user has."), fetchedResultsController?.fetchedObjects?.count ?? 0)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlacesTableViewCell.reuseIdentifier, for: indexPath) as! PlacesTableViewCell
            guard let favorite = fetchedResultsController?.object(at: indexPath) else { return cell }
            
            cell.icon.image = UIImage(named: "\(favorite.maki ?? "marker")-11", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: nil)
            
            cell.placeName.text = favorite.name
            cell.secondaryDetail.text = favorite.formattedAddressLines?.first
            let scope = MBPlacemarkScope(rawValue: UInt(favorite.scope))
            cell.iconBackgroundView.backgroundColor = scope.displayColor
            
            return cell
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if pulleyViewController?.drawerPosition == .open { pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true) }
        
        if !isShowingFavorites {
            let isResultsCell = !shouldShowDefaultResults ? mapSearchResults.indices.contains(indexPath.row) : defaultResults.indices.contains(indexPath.row)
            
            if isResultsCell {
                let placemark = !shouldShowDefaultResults ? mapSearchResults[indexPath.row] : defaultResults[indexPath.row]
                
                if let vc = storyboard?.instantiateViewController(withIdentifier: PlacesDetailViewController.identifier) as? PlacesDetailViewController {
                    vc.placemark = placemark
                    present(vc, animated: true) {
                        self.view.alpha = 0
                    }
                }
            } else {
                isShowingFavorites = true
            }
        } else {
            guard let placemark = fetchedResultsController?.fetchedObjects?[indexPath.row] else { return }
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: PlacesDetailViewController.identifier) as? PlacesDetailViewController {
                vc.tempFavorite = placemark
                vc.ofFavoritesOrigin = true
                present(vc, animated: true) {
                    self.view.alpha = 0
                }
            }
        }
    }
}

// MARK: - Pulley drawer delegate

extension PlacesViewController: PulleyDrawerViewControllerDelegate {
    @objc func expand() -> Bool {
        return pulleyViewController?.expand() ?? false
    }
    
    @objc func collapse() -> Bool {
        return pulleyViewController?.collapse() ?? false
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        if let presentedVC = presentedViewController as? PulleyDrawerViewControllerDelegate {
            if let supportedPositions = presentedVC.supportedDrawerPositions?() {
                return supportedPositions
            }
        }
        
        return PulleyPosition.all
    }
    
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
        
        headerSpacingConstraint.constant = drawer.drawerPosition == .collapsed ? bottomSafeArea : 0
                
        placesTableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        if drawer.drawerPosition != .open { searchBar.text = nil; searchBar.resignFirstResponder() }
        
        topGripperView.accessibilityValue = drawer.drawerPosition.localizedDescription
        bottomGripperView.accessibilityValue = drawer.drawerPosition.localizedDescription
        
        topGripperView.accessibilityFrame = view.convert(topGripperView.frame.insetBy(dx: -20, dy: -30), to: UIApplication.shared.keyWindow)
        bottomGripperView.accessibilityFrame = view.convert(bottomGripperView.frame.insetBy(dx: -20, dy: -30), to: UIApplication.shared.keyWindow)
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
        isShowingFavorites = false
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userActivity?.needsSave = true
        guard !searchText.isEmpty else { shouldShowDefaultResults = true; return }
        shouldShowDefaultResults = false
        previousMapSearchTask?.cancel()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchMap(for:)), with: searchText, afterDelay: 0.5)
    }
    
    func generateDefaultResults() {
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

extension PulleyViewController {
    func expand() -> Bool {
        switch drawerPosition {
        case .collapsed:
            setDrawerPosition(position: .partiallyRevealed, animated: true)
            return true
        case .partiallyRevealed:
            setDrawerPosition(position: .open, animated: true)
            return true
        default:
            return false
        }
    }
    
    func collapse() -> Bool {
        switch drawerPosition {
        case .partiallyRevealed:
            setDrawerPosition(position: .collapsed, animated: true)
            return true
        case .open:
            setDrawerPosition(position: .partiallyRevealed, animated: true)
            return true
        default:
            return false
        }
    }
}

extension PulleyPosition {
    var localizedDescription: String? {
        switch self {
        case .collapsed:
            return NSLocalizedString("Collapsed", comment: "Represents the collapsed position of an interface element.")
        case .partiallyRevealed:
            return NSLocalizedString("Partially Revealed", comment: "Represents the partially revealed position of an interface element.")
        case .open:
            return NSLocalizedString("Open", comment: "Represents the open position of an interface element.")
        case .closed:
            return NSLocalizedString("Closed", comment: "Represents the closed position of an interface element.")
        default:
            return nil
        }
    }
}
