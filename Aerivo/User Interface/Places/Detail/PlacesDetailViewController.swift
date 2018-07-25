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
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    var initialHeaderHeightSet = false
    lazy var cachedHeaderHeight: CGFloat = {
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return height
    }()
    
    lazy var openAQClient: OpenAQClient = .shared
    var latestAQ: LatestAQ?
    var parametersInfo: AerivoKit.Parameter?
    
    lazy var nwqpClient: NWQPClient = .shared
    var nwqpResults: [NWQPResult] = [] {
        didSet {
            nwqpResults = nwqpResults.filter { $0.organizations?.first?.activity.last?.results.last?.description.measurement != nil }
        }
    }
    
    var isAQDataLoaded = false {
        didSet {
            if isAQDataLoaded {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                    if self.isAQDataLoaded && self.isNWQPDataLoaded { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
                }
            }
        }
    }
    
    var isNWQPDataLoaded = false {
        didSet {
            if isNWQPDataLoaded {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                    if self.isAQDataLoaded && self.isNWQPDataLoaded { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeName.text = placemark.formattedName
        detail.text = placemark.genres?.first ?? placemark.address ?? ""
        address.text = placemark.formattedAddressLines.joined(separator: "\n")
        if let pulleyVC = presentingViewController?.pulleyViewController { drawerDisplayModeDidChange(drawer: pulleyVC) }
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize }
        collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
        
        close.layer.cornerRadius = close.layer.bounds.width/2
        close.layer.masksToBounds = true
        if !initialHeaderHeightSet { headerViewHeightConstraint.constant = cachedHeaderHeight; initialHeaderHeightSet = true }
    }
    
    private func fetchAirQualityData() {
        guard let coordinate = placemark.location?.coordinate else { return }
        var latestAQParams = LatestAQParameters()
        latestAQParams.coordinates = coordinate
        latestAQParams.radius = 800000
        latestAQParams.orderBy = .distance
        latestAQParams.limit = 1
        
        var isLatestAQLoaded = false
        var isParametersInfoLoaded = false
        
        var allDataIsLoaded: Bool {
            return isLatestAQLoaded && isParametersInfoLoaded
        }
        
        openAQClient.fetchLatestAQ(using: latestAQParams) { result in
            guard case let .success(latestAQ) = result else { return }
            self.latestAQ = latestAQ
            isLatestAQLoaded = true
            if allDataIsLoaded { self.isAQDataLoaded = true }
        }
        
        let parametersParams = ParameterParameters()
        openAQClient.fetchParameters(using: parametersParams) { result in
            guard case let .success(parameters) = result else { return }
            self.parametersInfo = parameters
            isParametersInfoLoaded = true
            if allDataIsLoaded { self.isAQDataLoaded = true }
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
        
        var isBeckBioticIndexLoaded = false
        var isBrillouinTaxonomicDiversityIndexLoaded = false
        var isDissolvedOxygenLoaded = false
        var isWaterTemperatureLoaded = false
        var isTurbiditySeverityLoaded = false
        var isHydrocarbonsLoaded = false
        
        var allDataIsLoaded: Bool {
            return isBeckBioticIndexLoaded && isBrillouinTaxonomicDiversityIndexLoaded && isDissolvedOxygenLoaded && isWaterTemperatureLoaded && isTurbiditySeverityLoaded && isHydrocarbonsLoaded
        }
        
        // Beck Biotic Index
        nwqpParameters.characteristicName = .beckBioticIndex
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(beckBioticIndexResult) = result else { return }
            self.nwqpResults.append(beckBioticIndexResult)
            isBeckBioticIndexLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
        }
        
        // Brillouin Taxonomic Diversity Index
        nwqpParameters.characteristicName = .brillouinTaxonomicDiversityIndex
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(brillouinTaxonomicDiversityIndexResult) = result else { return }
            self.nwqpResults.append(brillouinTaxonomicDiversityIndexResult)
            isBrillouinTaxonomicDiversityIndexLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
        }
        
        // Dissolved Oxygen
        nwqpParameters.characteristicName = .dissolvedOxygen
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(dissolvedOxygen) = result else { return }
            self.nwqpResults.append(dissolvedOxygen)
            isDissolvedOxygenLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
        }
        
        // Water Temperature
        nwqpParameters.characteristicName = .waterTemperature
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(waterTemperature) = result else { return }
            self.nwqpResults.append(waterTemperature)
            isWaterTemperatureLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
        }
        
        // Turbidity Severity
        nwqpParameters.characteristicName = .turbiditySeverity
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(turbiditySeverity) = result else { return }
            self.nwqpResults.append(turbiditySeverity)
            isTurbiditySeverityLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
        }
        
        // Hydrocarbons
        nwqpParameters.characteristicName = .hydrocarbons
        nwqpClient.fetchResults(using: nwqpParameters) { result in
            guard case let .success(hydrocarbons) = result else { return }
            self.nwqpResults.append(hydrocarbons)
            isHydrocarbonsLoaded = true
            if allDataIsLoaded { self.isNWQPDataLoaded = true }
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
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sections = 0
        if let firstResult = latestAQ?.results.first?.measurements, !firstResult.isEmpty /* Return an extra section for each extra quality we have. */ { sections += 1 }
        if !nwqpResults.isEmpty /* Return an extra section for each extra quality we have. */ { sections += 1 }
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if let latestAQ = latestAQ?.results.first /* Return air quality data in this section. */ {
                return latestAQ.measurements.count
            } else /* Return water quality data in this section. */ {
                return nwqpResults.count
            }
        } else if section == 1 /* Return water quality data in this section. */ {
            return nwqpResults.count
        } else {
            fatalError("Unexpected amount of collection view sections.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "placesDetailHeading", for: indexPath)
        if indexPath.section == 0 {
            if latestAQ?.results.first != nil /* Return air quality data in this section. */ {
                (headerView.viewWithTag(1) as? UILabel)?.text = NSLocalizedString("Air Quality", comment: "The air quality at a specified location.")
            } else /* Return water quality data in this section. */ {
                (headerView.viewWithTag(1) as? UILabel)?.text = NSLocalizedString("Water Quality", comment: "The water quality at a specified location.")
            }
        } else if indexPath.section == 1 /* Return water quality data in this section. */ {
            (headerView.viewWithTag(1) as? UILabel)?.text = NSLocalizedString("Water Quality", comment: "The water quality at a specified location.")
        } else {
            fatalError("Unexpected amount of collection view sections.")
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlacesDetailCollectionViewCell.reuseIdentifier, for: indexPath) as! PlacesDetailCollectionViewCell
        
        if indexPath.section == 0, let latestAQ = latestAQ /* Return air quality data in this section. */ {
            guard let aqResult = latestAQ.results.first?.measurements[indexPath.row] else { return cell }
            guard let parameterInfo = parametersInfo?.results.filter({ $0.id == aqResult.parameter.rawValue }).first else { return cell }
            let measurement = Measurement(value: aqResult.value, unit: aqResult.unit.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if aqResult.unit.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurement)
            let localizedString = String.localizedStringWithFormat("%@: %@", parameterInfo.name, localizedMeasurement)
            cell.detailLabel.text = localizedString
        } else /* Return water quality data in this section. */ {
            guard let nwqpResult = nwqpResults[indexPath.row].organizations?.first?.activity.last?.results.last else { return cell }
            guard let measurementInfo = nwqpResult.description.measurement else { return cell }
            let measurement = Measurement(value: measurementInfo.value, unit: measurementInfo.unitCode.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if measurementInfo.unitCode.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurement)
            let localizedString = String.localizedStringWithFormat("%@: %@", nwqpResult.description.characteristicName.rawValue, localizedMeasurement)
            cell.detailLabel.text = localizedString
        }
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    // MARK: - Actions
    
    @IBAction func contactOfficial(_ sender: UIButton) {
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.view.alpha = 1
        dismiss(animated: true)
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
            headerViewHeightConstraint.constant = drawer.collapsedDrawerHeight(bottomSafeArea: bottomSafeArea)
        } else {
            headerViewHeightConstraint.constant = cachedHeaderHeight
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
