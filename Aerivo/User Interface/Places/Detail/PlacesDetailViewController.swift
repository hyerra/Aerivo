//
//  PlacesDetailViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/20/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit
import MessageUI

class PlacesDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static let identifier = "placesDetailVC"
    
    var placemark: GeocodedPlacemark!
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var close: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topGripperView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var bottomGripperView: UIView!
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSpacingConstraint: NSLayoutConstraint!
    
    lazy var openAQClient: OpenAQClient = .shared
    var latestAQ: LatestAQ?
    var parametersInfo: AerivoKit.Parameter?
    
    lazy var nwqpClient: NWQPClient = .shared
    var nwqpResults: [NWQPResult] = [] {
        didSet {
            nwqpResults = nwqpResults.filter { $0.organizations?.first?.activity.last?.results.last?.description.measurement != nil }
        }
    }
    
    lazy var civicInformationClient: CivicInformationClient = .shared
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateCollectionViewLayout), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Do any cleanup after the view has disappeared.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Do any additional setup before the view will layout the subviews.
        createViewBlurEffect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after the view laid out the subviews.
        close.layer.cornerRadius = close.layer.bounds.width / 2
        close.layer.masksToBounds = true
        
        activityHeightConstraint.constant = activityIndicator.intrinsicContentSize.height + 15
        activityIndicator.layer.cornerRadius = activityIndicator.bounds.height / 8
        activityIndicator.layer.masksToBounds = true
    }
    
    @objc private func invalidateCollectionViewLayout() {
        collectionView.reloadData()
        collectionViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
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
        if let blurEffectView = view.subviews.first as? UIVisualEffectView { blurEffectView.frame = view.bounds; return }
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
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlacesDetailHeaderCollectionReusableView.reuseIdentifier, for: indexPath)
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
            let localizedString = String.localizedStringWithFormat("#%@:# %@", parameterInfo.name, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: [.font : UIFont.preferredFont(forTextStyle: .footnote), .foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            cell.detail.setAttributedTitle(attributedString, for: .normal)
            cell.parameterDescription = parameterInfo.information
        } else /* Return water quality data in this section. */ {
            guard let nwqpResult = nwqpResults[indexPath.row].organizations?.first?.activity.last?.results.last else { return cell }
            guard let measurementInfo = nwqpResult.description.measurement else { return cell }
            let measurement = Measurement(value: measurementInfo.value, unit: measurementInfo.unitCode.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if measurementInfo.unitCode.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurement)
            let localizedString = String.localizedStringWithFormat("#%@:# %@", nwqpResult.description.characteristicName.rawValue, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: [.font : UIFont.preferredFont(forTextStyle: .footnote), .foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            cell.detail.setAttributedTitle(attributedString, for: .normal)
            cell.parameterDescription = nwqpResult.description.information
        }
        
        cell.parameterDescriptionDelegate = self
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // TODO: Once self sizing headers come out use those. For now we need to generate the height of the cell hackily.
        return CGSize(width: collectionView.bounds.width, height: UIFont.preferredFont(forTextStyle: .headline).lineHeight + 16)
    }
    
    // MARK: - Actions
    
    @IBAction func contactOfficial(_ sender: UIButton) {
        presentingViewController?.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        activityIndicator.startAnimating()
        sender.isUserInteractionEnabled = false
        
        var representativeInfoParams = RepresentativeInfoByAddressParameters()
        representativeInfoParams.address = placemark.formattedAddressLines.joined(separator: " ")
        representativeInfoParams.levels = [.administrativeArea1, .administrativeArea2, .locality, .regional, .special, .subLocality1, .subLocality2]
        representativeInfoParams.roles = [.deputyHeadOfGovernment, .executiveCouncil, .governmentOfficer, .headOfGovernment, .headOfState, .legislatorLowerBody, .legislatorUpperBody]
        civicInformationClient.fetchRepresentativeInfo(using: representativeInfoParams) { result in
            self.activityIndicator.stopAnimating()
            sender.isUserInteractionEnabled = true
            
            if case let .success(representativeInfo) = result {
                func showNoDataAlert() {
                    let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                    let alertController = UIAlertController(title: NSLocalizedString("Oops 😣", comment: "Title of alert control for not enough data error."), message: "\(appName) \(NSLocalizedString("doesn't have enough information about government officials for your area. You can try to find governement information directly or contact us directly for a request to support your area.", comment: "Message of alert controller for not enough data error."))", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                    self.present(alertController, animated: true)
                }
                
                guard let officials = representativeInfo.officials else { showNoDataAlert(); return }
                let filteredOfficials = officials.filter { $0.emails != nil || $0.phones != nil || $0.channels != nil }
                
                let alertController = UIAlertController(title: NSLocalizedString("Government Officials", comment: "Title for a list of governement officials a user can contact."), message: NSLocalizedString("Choose one of the government officials you wish to contact.", comment: "Message for a list of government officials a user can contact."), preferredStyle: .actionSheet)
                
                for official in filteredOfficials {
                    let title = official.name + (official.party != nil ? "" : "")
                    let action = UIAlertAction(title: title, style: .default) { action in
                        let alertController = UIAlertController(title: NSLocalizedString("Contact Methods", comment: "Title for how the user would like to contact their governement official."), message: NSLocalizedString("How would you like to contact him/her?", comment: "Message for how the user would like to contact their government official."), preferredStyle: .actionSheet)
                        
                        if let phones = official.phones, !phones.isEmpty {
                            let action = UIAlertAction(title: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), style: .default) { action in
                                let alertController = UIAlertController(title: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), message: NSLocalizedString("Choose a number to call your government official.", comment: "Message that tells the user to select a phone number."), preferredStyle: .actionSheet)
                                
                                for phone in phones {
                                    let action = UIAlertAction(title: NSLocalizedString(phone, comment: "Tells the user they can call their governement official."), style: .default) { action in
                                        guard let url = URL(string: "telprompt://\(phone)") else { return }
                                        UIApplication.shared.open(url)
                                    }
                                    alertController.addAction(action)
                                }
                                
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                
                                self.present(alertController, animated: true)
                            }
                            alertController.addAction(action)
                        }
                        
                        if let emails = official.emails, !emails.isEmpty {
                            let action = UIAlertAction(title: NSLocalizedString("Email", comment: "Tells the user they can email their governement official."), style: .default) { action in
                                func showEmailCannotBeSentAlert() {
                                    let alertController = UIAlertController(title: NSLocalizedString("Email Cannot Be Sent", comment: "Title of error telling the user that an email cannot be sent."), message: NSLocalizedString("This device cannot send emails.", comment: "Message of error telling the user that email cannot be sent."), preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                    self.present(alertController, animated: true)
                                }
                                
                                let alertController = UIAlertController(title: NSLocalizedString("Email", comment: "Tells the user they can email their governement official."), message: NSLocalizedString("Choose an email to contact your government official.", comment: "Message that tells the user to select an email."), preferredStyle: .actionSheet)
                                
                                for email in emails {
                                    let action = UIAlertAction(title: email, style: .default) { action in
                                        guard MFMailComposeViewController.canSendMail() else { showEmailCannotBeSentAlert(); return }
                                        let composeVC = MFMailComposeViewController()
                                        composeVC.mailComposeDelegate = self
                                        composeVC.setToRecipients([email])
                                        composeVC.setSubject(CivicInformationMessage.subject(placeName: self.placemark.formattedName).messageValue)
                                        composeVC.setMessageBody(CivicInformationMessage.messageBody(officialsName: official.name, placeName: self.placemark.formattedName).messageValue, isHTML: false)
                                        self.present(composeVC, animated: true)
                                    }
                                    alertController.addAction(action)
                                }
                                
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                self.present(alertController, animated: true)
                            }
                            alertController.addAction(action)
                        }
                        
                        if let channels = official.channels, !channels.isEmpty {
                            let action = UIAlertAction(title: NSLocalizedString("Social Media", comment: "Tells the connect with the official using social media."), style: .default) { action in
                                let alertController = UIAlertController(title: NSLocalizedString("Social Media", comment: "Tells the connect with the official using social media."), message: NSLocalizedString("Choose a social media platform to contact your government official.", comment: "Message that tells the user to select a social media account."), preferredStyle: .actionSheet)
                                
                                for channel in channels {
                                    switch channel.type {
                                    case "GooglePlus":
                                        let action = UIAlertAction(title: channel.type, style: .default) { action in
                                            guard let url = URL(string: "https://plus.google.com/\(channel.id)") else { return }
                                            UIApplication.shared.open(url)
                                        }
                                        alertController.addAction(action)
                                    case "YouTube":
                                        let action = UIAlertAction(title: channel.type, style: .default) { action in
                                            guard let url = URL(string: "https://www.youtube.com/user/\(channel.id)") else { return }
                                            UIApplication.shared.open(url)
                                        }
                                        alertController.addAction(action)
                                    case "Facebook":
                                        let action = UIAlertAction(title: channel.type, style: .default) { action in
                                            guard let url = URL(string: "https://www.facebook.com/\(channel.id)") else { return }
                                            UIApplication.shared.open(url)
                                        }
                                        alertController.addAction(action)
                                    case "Twitter":
                                        let action = UIAlertAction(title: channel.type, style: .default) { action in
                                            guard let url = URL(string: "https://twitter.com/\(channel.id)") else { return }
                                            UIApplication.shared.open(url)
                                        }
                                        alertController.addAction(action)
                                    default:
                                        break
                                    }
                                }
                                
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                self.present(alertController, animated: true)
                            }
                            
                            alertController.addAction(action)
                        }
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                        
                        self.present(alertController, animated: true)
                    }
                    alertController.addAction(action)
                }
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                self.present(alertController, animated: true)
            } else {
                let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                let alertController = UIAlertController(title: NSLocalizedString("Oops 😣", comment: "Title of alert control for network error."), message: "\(appName) \(NSLocalizedString("is having trouble getting government representative information. This may be because the app doesn't have enough information about government officials for your area.", comment: "Message of alert controller for network error."))", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                self.present(alertController, animated: true)
            }
        }
    }
    
    @IBAction func showInfo(_ sender: UIButton) {
        if let wikiID = placemark.wikidataItemIdentifier {
            guard let url = URL(string: "https://www.wikidata.org/wiki/\(wikiID)") else { return }
            UIApplication.shared.open(url)
        } else {
            guard var urlComps = URLComponents(string: "https://www.google.com/search") else { return }
            let searchQuery = URLQueryItem(name: "q", value: placemark.qualifiedName ?? placemark.formattedName)
            urlComps.queryItems = [searchQuery]
            guard let url = urlComps.url else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.view.alpha = 1
        let tempPresentingViewController = presentingViewController // Retain a reference to the presenting view controller before dismissing.
        dismiss(animated: true) {
            guard let mapView = (tempPresentingViewController?.pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView else { return }
            mapView.removeAnnotations(mapView.annotations ?? [])
        }
    }
}

// MARK: - Parameter description delegate

extension PlacesDetailViewController: ParameterDescriptionDelegate {
    func show(parameterDescription: ParameterDescriptionPopoverViewController) {
        present(parameterDescription, animated: true)
    }
}

// MARK: - Pulley drawer delegate

extension PlacesDetailViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return headerView.bounds.height - headerSpacingConstraint.constant + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        loadViewIfNeeded()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSafeArea, right: 0)
        
        if drawer.drawerPosition == .collapsed {
            headerSpacingConstraint.constant = bottomSafeArea
        } else {
            headerSpacingConstraint.constant = 0
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
        
        if drawer.currentDisplayMode == .leftSide {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
    }
}

// MARK: - Mail compose delegate

extension PlacesDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if case .failed = result, let error = error {
            let alertController = UIAlertController(title: NSLocalizedString("Email Cannot Be Sent", comment: "Title of error telling the user that an email cannot be sent."), message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
            present(alertController, animated: true)
        }
        controller.dismiss(animated: true)
    }
}
