//
//  PlacesDetailViewController.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/20/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit
import Pulley
import ARKit
import Mapbox
import MapboxGeocoder
import CoreData
import IntentsUI
import MessageUI
import SafariServices

class PlacesDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static let identifier = "placesDetailVC"
    
    var placemark: Placemark!
    var favorite: Favorite? {
        didSet {
            if favorite != nil {
                favoriteIcon.tintColor = UIColor(named: "Gold Color")
                favoriteLabel.textColor = UIColor(named: "Gold Color")
            } else {
                favoriteIcon.tintColor = UIColor(named: "System Green Color")
                favoriteLabel.textColor = UIColor(named: "System Green Color")
            }
        }
    }
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var headerStackView: UIStackView!
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
    
    @IBOutlet weak var contactOfficialView: UIView!
    
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var addSiriStackView: UIStackView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSpacingConstraint: NSLayoutConstraint!
    
    @available(iOS 12.0, *)
    lazy var intent = AirQualityIntent(placemark: placemark)
    @available(iOS 12.0, *)
    lazy var interaction = INInteraction(airQualityIntent: intent, response: nil)
    
    lazy var managedObjectContext = DataController.shared.persistentContainer.newBackgroundContext()
    
    lazy var openAQClient: OpenAQClient = .shared
    var latestAQ: LatestAQ?
    var parametersInfo: AerivoKit.Parameter?
    var openAQTasks: [URLSessionDataTask] = []
    
    lazy var nwqpClient: NWQPClient = .shared
    var nwqpTasks: [URLSessionDataTask] = []
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
        placeName.text = placemark.displayName
        detail.text = placemark?.genres?.first ?? placemark.addressLines?.first
        address.text = placemark.addressLines?.joined(separator: "\n")
        
        if let pulleyVC = presentingViewController?.pulleyViewController { drawerDisplayModeDidChange(drawer: pulleyVC) }
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize }
        
        userActivity = createUserActivity()
        setupAccessibility()
        
        fetchAirQualityData()
        fetchWaterQualityData()
        
        if #available(iOS 12.0, *) {
            interaction.donate()
            showAddSiriButton()
        }
        
        ReviewManager.requestReview(for: .locationViewed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup right before the view will appear.
        updateMap()
        checkIfFavoritedLocation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Do any layout related work when the interface environment changes.
        optionsStackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        view.layoutIfNeeded()
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
    
    weak var tempPresentingVC: UIViewController?
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Do any additional teardown right before the view will disappear.
        tempPresentingVC = presentingViewController
        tempPresentingVC?.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
        tempPresentingVC?.view.alpha = 1
        (tempPresentingVC as? PlacesViewController)?.isShowingFavorites = false
        if let mapView = (tempPresentingVC?.pulleyViewController?.primaryContentViewController as? MapViewController)?.mapView {
            mapView.removeAnnotations(mapView.annotations ?? [])
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Do any additional teardown after the view disappeared.
        if let tempPresentingVC = tempPresentingVC {
            tempPresentingVC.pulleyViewController?.setDrawerContentViewController(controller: tempPresentingVC, animated: false)
        }
    }
    
    deinit {
        openAQTasks.forEach { if $0.state == .running { $0.cancel() } }
        nwqpTasks.forEach { if $0.state == .running { $0.cancel() } }
    }
    
    // MARK: - Update map
    
    private func updateMap() {
        guard let mapViewController = (presentingViewController?.pulleyViewController?.primaryContentViewController as? MapViewController) else { return }
        guard let mapView = mapViewController.mapView else { return }
        mapView.removeAnnotations(mapView.annotations ?? [])
        
        if let latitude = placemark.latitude, let longitude = placemark.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
            mapViewController.annotationBackgroundColor = placemark.relativeScope.displayColor
            mapViewController.annotationImage = UIImage(named: "\(placemark.maki ?? "marker")-15", in: Bundle(identifier: "com.harishyerra.AerivoKit"), compatibleWith: traitCollection)
            
            let pointAnnotation = MGLPointAnnotation()
            pointAnnotation.coordinate = coordinate
            pointAnnotation.title = placemark.displayName
            pointAnnotation.subtitle = placemark.genres?.first
            mapView.addAnnotation(pointAnnotation)
            
            let camera = MGLMapCamera()
            camera.centerCoordinate = coordinate
            camera.altitude = 8000
            mapView.fly(to: camera) {
                mapView.setCenter(coordinate, animated: true)
            }
        }
    }
    
    // MARK: - Intents
    
    @available(iOS 12.0, *)
    private func showAddSiriButton() {
        let addShortcutButton = INUIAddVoiceShortcutButton(style: .white)
        addShortcutButton.backgroundColor = #colorLiteral(red: 0.6700000167, green: 0.6700000167, blue: 0.6700000167, alpha: 0.25)
        addShortcutButton.shortcut = INShortcut(intent: intent)
        addShortcutButton.delegate = self
        
        addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
        addSiriStackView.addArrangedSubview(addShortcutButton)
    }
    
    // MARK: - User Activity
    
    private func createUserActivity() -> NSUserActivity {
        let activity = NSUserActivity.viewPlaceActivity
        activity.title = String.localizedStringWithFormat(NSLocalizedString("Fetch environmental info for %@", comment: "String that will be displayed that allows a user to view enviornmental quality at a location."), placemark.displayName ?? "")
        if let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue {
            if #available(iOS 12.0, *) { activity.persistentIdentifier = "latitude:\(latitude),longitude:\(longitude)" }
            let userInfo: [String: Any] =  [NSUserActivity.ActivityKeys.location: ["latitude": latitude, "longitude": longitude]]
            activity.addUserInfoEntries(from: userInfo)
        }
        return activity
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibility() {
        let headerElement = UIAccessibilityElement(accessibilityContainer: headerView)
        headerElement.accessibilityTraits = .staticText
        headerElement.accessibilityLabel = (placeName.text?.appending(" ") ?? "") + (detail.text ?? "")
        headerElement.accessibilityFrameInContainerSpace = headerView.bounds
        headerView.accessibilityElements = [topGripperView, headerElement, close]
        
        contactOfficialView.allSubviews.forEach { $0.accessibilityIgnoresInvertColors = true }
        
        optionsStackView.subviews.forEach {
            $0.subviews.forEach { subview in
                if let subview = subview as? UIStackView {
                    subview.allSubviews.forEach { $0.accessibilityIgnoresInvertColors = true }
                }
            }
        }
        
        topGripperView.accessibilityCustomActions = [UIAccessibilityCustomAction(name: NSLocalizedString("Expand", comment: "Action for expanding the card overlay screen."), target: self, selector: #selector(expand)), UIAccessibilityCustomAction(name: NSLocalizedString("Collapse", comment: "Action for collapsing the card overlay screen."), target: self, selector: #selector(collapse))]
        bottomGripperView.accessibilityCustomActions = [UIAccessibilityCustomAction(name: NSLocalizedString("Expand", comment: "Action for expanding the card overlay screen."), target: self, selector: #selector(expand)), UIAccessibilityCustomAction(name: NSLocalizedString("Collapse", comment: "Action for collapsing the card overlay screen."), target: self, selector: #selector(collapse))]
    }
    
    // MARK: - Core Data
    
    private func checkIfFavoritedLocation() {
        guard let qualifiedName = placemark?.qualifiedName else { return } // Make sure the qualified name is there or we have nothing to check if this placemark exists.
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let predicate = NSPredicate(format: "qualifiedName = %@", qualifiedName)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            let favorites = try DataController.shared.managedObjectContext.fetch(fetchRequest)
            favorite = favorites.first
        } catch let error {
            #if DEBUG
            print(error)
            #endif
        }
    }
        
    private func fetchAirQualityData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
        
        let latestAQTask = openAQClient.fetchLatestAQ(using: latestAQParams) { [weak self] result in
            guard case let .success(latestAQ) = result else {
                isLatestAQLoaded = true
                if allDataIsLoaded { self?.isAQDataLoaded = true }
                return
            }
            self?.latestAQ = latestAQ
            isLatestAQLoaded = true
            if allDataIsLoaded { self?.isAQDataLoaded = true }
        }
        openAQTasks.append(latestAQTask)
        
        let parametersParams = ParameterParameters()
        let parametersTask = openAQClient.fetchParameters(using: parametersParams) { [weak self] result in
            guard case let .success(parameters) = result else {
                isParametersInfoLoaded = true
                if allDataIsLoaded { self?.isAQDataLoaded = true }
                return
            }
            self?.parametersInfo = parameters
            isParametersInfoLoaded = true
            if allDataIsLoaded { self?.isAQDataLoaded = true }
        }
        openAQTasks.append(parametersTask)
    }
    
    private func fetchWaterQualityData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
        
        nwqpTasks = nwqpClient.fetchAllResults(using: nwqpParameters) { [weak self] results in
            for result in results {
                guard case let .success(parameter) = result else { continue }
                self?.nwqpResults.append(parameter)
            }
            self?.isNWQPDataLoaded = true
        }
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
            let localizedString = String.localizedStringWithFormat(NSLocalizedString("#%@:# %@", comment: "The first token contains the parameter name and the second token contains the value. The # symbol should be placed around the parameter name. An example would be #SO2:# 1 ppm."), parameterInfo.localizedName ?? parameterInfo.name, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: [.foregroundColor : UIAccessibility.isInvertColorsEnabled ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
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
            let localizedString = String.localizedStringWithFormat(NSLocalizedString("#%@:# %@", comment: "The first token contains the parameter name and the second token contains the value. The # symbol should be placed around the parameter name. An example would be #Temperature, water:# 72°F."), nwqpResult.description.characteristicName.rawValue, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: [.foregroundColor : UIAccessibility.isInvertColorsEnabled ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
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
        representativeInfoParams.address = placemark.addressLines?.joined(separator: " ")
        representativeInfoParams.levels = [.administrativeArea1, .administrativeArea2, .locality, .regional, .special, .subLocality1, .subLocality2]
        representativeInfoParams.roles = [.deputyHeadOfGovernment, .executiveCouncil, .governmentOfficer, .headOfGovernment, .headOfState, .legislatorLowerBody, .legislatorUpperBody]
        civicInformationClient.fetchRepresentativeInfo(using: representativeInfoParams) { result in
            self.activityIndicator.stopAnimating()
            sender.isUserInteractionEnabled = true
            
            if case let .success(representativeInfo) = result {
                func showNoDataAlert() {
                    let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                    let localizedMessage = String.localizedStringWithFormat(NSLocalizedString("%@ doesn't have enough information about government officials for your area. You can try to find governement information directly or contact us directly for a request to support your area.", comment: "An error message that notifies the user that there isn't enough data about governement officials in a specified region."), appName)
                    let alertController = UIAlertController(title: NSLocalizedString("Oops 😣", comment: "Title of alert control for not enough data error."), message: localizedMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                    self.present(alertController, animated: true)
                }
                
                guard let officials = representativeInfo.officials else { showNoDataAlert(); return }
                let filteredOfficials = officials.filter { !($0.emails ?? []).isEmpty || !($0.phones ?? []).isEmpty || !($0.channels ?? []).isEmpty }
                guard !filteredOfficials.isEmpty else { showNoDataAlert(); return }
                
                let alertController = UIAlertController(title: NSLocalizedString("Government Officials", comment: "Title for a list of governement officials a user can contact."), message: NSLocalizedString("Choose one of the government officials you wish to contact.", comment: "Message for a list of government officials a user can contact."), preferredStyle: .actionSheet)
                
                for official in filteredOfficials {
                    let title = official.name + (official.party != nil ? "" : "")
                    let action = UIAlertAction(title: title, style: .default) { action in
                        let alertController = UIAlertController(title: NSLocalizedString("Contact Methods", comment: "Title for how the user would like to contact their governement official."), message: NSLocalizedString("How would you like to contact him/her?", comment: "Message for how the user would like to contact their government official."), preferredStyle: .actionSheet)
                        
                        if let phones = official.phones, !phones.isEmpty {
                            let action = UIAlertAction(title: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), style: .default) { action in
                                let alertController = UIAlertController(title: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), message: NSLocalizedString("Choose a number to call your government official.", comment: "Message that tells the user to select a phone number."), preferredStyle: .actionSheet)
                                
                                for phone in phones {
                                    let action = UIAlertAction(title: phone, style: .default) { action in
                                        var components = URLComponents()
                                        components.scheme = "tel"
                                        components.path = phone
                                        guard let url = components.url else { return }
                                        UIApplication.shared.open(url)
                                    }
                                    alertController.addAction(action)
                                }
                                
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                alertController.popoverPresentationController?.sourceView = sender
                                alertController.popoverPresentationController?.sourceRect = sender.bounds
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
                                        if let name = self.placemark.displayName {
                                            composeVC.setSubject(CivicInformationMessage.subject(placeName: name).messageValue)
                                            composeVC.setMessageBody(CivicInformationMessage.messageBody(officialsName: official.name, placeName: name).messageValue, isHTML: false)
                                        }
                                        self.present(composeVC, animated: true)
                                    }
                                    alertController.addAction(action)
                                }
                                
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                                alertController.popoverPresentationController?.sourceView = sender
                                alertController.popoverPresentationController?.sourceRect = sender.bounds
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
                                alertController.popoverPresentationController?.sourceView = sender
                                alertController.popoverPresentationController?.sourceRect = sender.bounds
                                self.present(alertController, animated: true)
                            }
                            
                            alertController.addAction(action)
                        }
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                        alertController.popoverPresentationController?.sourceView = sender
                        alertController.popoverPresentationController?.sourceRect = sender.bounds
                        self.present(alertController, animated: true)
                    }
                    alertController.addAction(action)
                }
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                alertController.popoverPresentationController?.sourceView = sender
                alertController.popoverPresentationController?.sourceRect = sender.bounds
                self.present(alertController, animated: true)
            } else {
                let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                let localizedMessage = String.localizedStringWithFormat(NSLocalizedString("%@ is having trouble getting government representative information. This is likely due to a lack of government representative data for this region.", comment: "An error message that notifies the user that there isn't enough data about governement officials in a specified region."), appName)
                let alertController = UIAlertController(title: NSLocalizedString("Oops 😣", comment: "Title of alert control for network error."), message: localizedMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                self.present(alertController, animated: true)
            }
        }
    }
    
    @IBAction func favoritePlacemark(_ sender: UIButton) {
        let dataController = DataController.shared
        if favorite == nil {
            guard let placemark = placemark as? GeocodedPlacemark else { return }
            let favorite = Favorite(placemark: placemark, insertInto: managedObjectContext)
            
            do {
                try dataController.save(context: managedObjectContext)
                self.favorite = favorite
            } catch {
                let alertController = UIAlertController(title: NSLocalizedString("Couldn't Favorite Location", comment: "Title of alert that tells the user that there was an error saving the location to their favorites."), message: NSLocalizedString("There was an issue saving this location to your favorites.", comment: "Message of alert that tells the user that there was an error saving the location to their favorites."), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                self.present(alertController, animated: true)
            }
        } else if let favorite = favorite {
            do {
                let favorite = try managedObjectContext.existingObject(with: favorite.objectID)
                managedObjectContext.delete(favorite)
                try dataController.save(context: managedObjectContext)
                self.favorite = nil
                if placemark is Favorite { dismiss(animated: true) }
            } catch {
                let alertController = UIAlertController(title: NSLocalizedString("Couldn't Remove Favorite Location", comment: "Title of alert that tells the user that there was an error removing the location from their favorites."), message: NSLocalizedString("There was an issue removing this location from your favorites.", comment: "Message of alert that tells the user that there was an error removing the location from their favorites."), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
                self.present(alertController, animated: true)
            }
        }
    }
    
    @IBAction func showInfo(_ sender: UIButton) {
        if let wikiID = placemark?.wikidataItemIdentifier ?? favorite?.wikidataItemIdentifier {
            guard let url = URL(string: "https://www.wikidata.org/wiki/\(wikiID)") else { return }
            let webViewController = SFSafariViewController(url: url)
            webViewController.preferredControlTintColor = UIColor(named: "System Green Color")
            present(webViewController, animated: true)
        } else {
            guard var urlComps = URLComponents(string: "https://www.google.com/search") else { return }
            let searchQuery = URLQueryItem(name: "q", value: placemark.qualifiedName ?? placemark.displayName)
            urlComps.queryItems = [searchQuery]
            guard let url = urlComps.url else { return }
            let webViewController = SFSafariViewController(url: url)
            webViewController.preferredControlTintColor = UIColor(named: "System Green Color")
            present(webViewController, animated: true)
        }
    }
    
    @IBAction func showAR(_ sender: UIButton) {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        let arPlacesVC = storyboard?.instantiateViewController(withIdentifier: ARPlacesViewController.identifier) as! ARPlacesViewController
        guard let latitude = placemark.latitude?.doubleValue else { return }
        guard let longitude = placemark.longitude?.doubleValue else { return }
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        arPlacesVC.location = location
        self.presentingViewController?.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        present(arPlacesVC, animated: true)
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true)
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
    @objc func expand() -> Bool {
        return presentingViewController?.pulleyViewController?.expand() ?? false
    }
    
    @objc func collapse() -> Bool {
        return presentingViewController?.pulleyViewController?.collapse() ?? false
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        if presentedViewController != nil { return [.open] }
        return PulleyPosition.all
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        view.layoutIfNeeded()
        return headerView.bounds.height - headerSpacingConstraint.constant + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        loadViewIfNeeded()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSafeArea, right: 0)
        
        headerSpacingConstraint.constant = drawer.drawerPosition == .collapsed ? bottomSafeArea : 0
        
        if drawer.drawerPosition != .open {
            presentedViewController?.dismiss(animated: true)
        }
        
        topGripperView.accessibilityValue = drawer.drawerPosition.localizedDescription
        bottomGripperView.accessibilityValue = drawer.drawerPosition.localizedDescription
        
        close.accessibilityFrame = view.convert(close.frame.insetBy(dx: -20, dy: -20), to: UIApplication.shared.keyWindow)
        topGripperView.accessibilityFrame = view.convert(topGripperView.frame.insetBy(dx: -20, dy: -30), to: UIApplication.shared.keyWindow)
        bottomGripperView.accessibilityFrame = view.convert(bottomGripperView.frame.insetBy(dx: -20, dy: -30), to: UIApplication.shared.keyWindow)
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        if drawer.currentDisplayMode == .drawer {
            topGripperView.alpha = 1
            bottomGripperView.alpha = 0
        } else {
            topGripperView.alpha = 0
            bottomGripperView.alpha = 1
        }
        
        if drawer.currentDisplayMode == .panel {
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

// MARK: - Intents UI delegate

@available(iOS 12.0, *)
extension PlacesDetailViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true)
    }
}

@available(iOS 12.0, *)
extension PlacesDetailViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error {
            let alertController = UIAlertController(title: NSLocalizedString("Shortcut Couldn't Be Added", comment: "Title of error telling the shortcut couldn't be added to Siri."), message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
            present(alertController, animated: true)
        }
        controller.dismiss(animated: true)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}

@available(iOS 12.0, *)
extension PlacesDetailViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error {
            let alertController = UIAlertController(title: NSLocalizedString("Shortcut Couldn't Be Updated", comment: "Title of error telling the shortcut couldn't be updated to Siri."), message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel))
            present(alertController, animated: true)
        }
        controller.dismiss(animated: true)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}
