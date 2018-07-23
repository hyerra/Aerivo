//
//  PlacesDetailViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/20/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit

class PlacesDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let identifier = "placesDetailVC"
    
    var placemark: GeocodedPlacemark!
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var close: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topGripperView: UIView!
    @IBOutlet weak var bottomGripperView: UIView!
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var headerHeightConstraint: NSLayoutConstraint?
    
    lazy var cachedHeaderHeight: CGFloat = {
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return height
    }()
    
    lazy var openAQClient: OpenAQClient = .shared
    var latestAQ: LatestAQ? {
        didSet {
            collectionView.performBatchUpdates({
                collectionView.reloadData()
            })
        }
    }
    
    lazy var nwqpClient: NWQPClient = .shared
    var nwqpResults: [NWQPResult] = [] {
        didSet {
            collectionView.performBatchUpdates({
                collectionView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeName.text = placemark.formattedName
        detail.text = placemark.genres?.first ?? placemark.address ?? ""
        address.text = placemark.qualifiedName
        if let pulleyVC = presentingViewController?.pulleyViewController { drawerDisplayModeDidChange(drawer: pulleyVC) }
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchAirQualityData()
        fetchWaterQualityData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        createViewBlurEffect()
        sizeHeaderToFit()
        
        close.layer.cornerRadius = close.layer.bounds.width/2
        close.layer.masksToBounds = true
    }
    
    private func fetchAirQualityData() {
        guard let coordinate = placemark.location?.coordinate else { return }
        var params = LatestAQParameters()
        params.coordinates = coordinate
        params.radius = 800000
        params.orderBy = .distance
        params.limit = 1
        openAQClient.fetchLatestAQ(using: params) { result in
            guard case let .success(latestAQ) = result else { return }
            self.latestAQ = latestAQ
        }
    }
    
    private func fetchWaterQualityData() {
        guard let coordinate = placemark.location?.coordinate else { return }
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        var nwqpParameters = NWQPParameters()
        nwqpParameters.latitude = coordinate.latitude
        nwqpParameters.longitude = coordinate.longitude
        nwqpParameters.within = 500
        nwqpParameters.zip = .no
        nwqpParameters.pageSize = 10
        nwqpParameters.page = 1
        nwqpParameters.startDate = startDate
        
        // Beck Biotic Index
        nwqpParameters.characteristicName = .beckBioticIndex
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(beckBioticIndexResult) = result else { return }
            self.nwqpResults.append(beckBioticIndexResult)
        }
        
        // Brillouin Taxonomic Diversity Index
        nwqpParameters.characteristicName = .brillouinTaxonomicDiversityIndex
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(brillouinTaxonomicDiversityIndexResult) = result else { return }
            self.nwqpResults.append(brillouinTaxonomicDiversityIndexResult)
        }
        
        // Dissolved Oxygen
        nwqpParameters.characteristicName = .dissolvedOxygen
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(dissolvedOxygen) = result else { return }
            self.nwqpResults.append(dissolvedOxygen)
        }
        
        // Water Temperature
        nwqpParameters.characteristicName = .waterTemperature
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(waterTemperature) = result else { return }
            self.nwqpResults.append(waterTemperature)
        }
        
        // Turbidity Severity
        nwqpParameters.characteristicName = .turbiditySeverity
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(turbiditySeverity) = result else { return }
            self.nwqpResults.append(turbiditySeverity)
        }
        
        // Hydrocarbons
        nwqpParameters.characteristicName = .hydrocarbons
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(hydrocarbons) = result else { return }
            self.nwqpResults.append(hydrocarbons)
        }
    }
    
    private func createViewBlurEffect() {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        blurEffectView.frame = view.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        view.insertSubview(blurEffectView, at: 0)
    }
    
    private func sizeHeaderToFit() {
        if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
        let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight)
        newConstraint.isActive = true
        headerHeightConstraint = newConstraint
    }
    
    // MARK: - Collection view data source
    
    // MARK: - Collection view delegate
    
    // MARK: - Actions
    
    @IBAction func contactOfficial(_ sender: UIButton) {
        
    }
    
}

// MARK: - Pulley drawer delegate

extension PlacesDetailViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return cachedHeaderHeight + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        loadViewIfNeeded()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSafeArea, right: 0)
        
        if drawer.drawerPosition == .collapsed {
            if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
            let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight + bottomSafeArea)
            newConstraint.isActive = true
            headerHeightConstraint = newConstraint
        } else {
            if let constraint = headerHeightConstraint { NSLayoutConstraint.deactivate([constraint]) }
            let newConstraint = headerView.heightAnchor.constraint(equalToConstant: cachedHeaderHeight)
            newConstraint.isActive = true
            headerHeightConstraint = newConstraint
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
