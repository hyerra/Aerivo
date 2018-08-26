//
//  PlaceDetailInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import AerivoKit
import Intents
import Foundation

class PlaceDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "placeDetailIC"
    
    var placemark: Placemark!
    
    @IBOutlet var location: WKInterfaceLabel!
    @IBOutlet var contactOfficialButton: WKInterfaceButton!
    
    @IBOutlet var airQualityLabel: WKInterfaceLabel!
    @IBOutlet var airQualityTable: WKInterfaceTable!
    
    @IBOutlet var waterQualityLabel: WKInterfaceLabel!
    @IBOutlet var waterQualityTable: WKInterfaceTable!
    
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
                    self.reloadAirQualityTable()
                }
            }
        }
    }
    
    var isNWQPDataLoaded = false {
        didSet {
            if isNWQPDataLoaded {
                DispatchQueue.main.async {
                    self.reloadWaterQualityTable()
                }
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        setTitle(NSLocalizedString("Back", comment: "Allows the user to go back to the previous screen."))
        self.placemark = context as? Placemark
        location.setText(placemark.displayName)
        loadAirQualityData()
        loadWaterQualityData()
        if #available(watchOS 5.0, *) {
            donateAirQualityIntent()
            update(createUserActivity())
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    deinit {
        openAQClient.cancelAllPendingRequests()
        nwqpClient.cancelAllPendingRequests()
    }
    
    // MARK: - Intents
    
    @available(watchOS 5.0, *)
    private func donateAirQualityIntent() {
        let intent = AirQualityIntent()
        
        if let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            intent.targetLocation = CLPlacemark(location: location, name: placemark.displayName, postalAddress: nil)
        }
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate()
    }
    
    // MARK: - User Activity
    
    private func createUserActivity() -> NSUserActivity {
        let viewPlaceActivity = NSUserActivity.viewPlaceActivity
        viewPlaceActivity.title = String.localizedStringWithFormat(NSLocalizedString("Fetch environmental info for %@", comment: "String that will be displayed that allows a user to view enviornmental quality at a location."), placemark.displayName ?? "")
        if let latitude = placemark.latitude?.doubleValue, let longitude = placemark.longitude?.doubleValue {
            if #available(watchOS 5.0, *) { viewPlaceActivity.persistentIdentifier = "latitude:\(latitude),longitude:\(longitude)" }
            let userInfo: [String: Any] =  [NSUserActivity.ActivityKeys.location: ["latitude": latitude, "longitude": longitude]]
            viewPlaceActivity.addUserInfoEntries(from: userInfo)
        }
        return viewPlaceActivity
    }
    
    // MARK: - Air Quality
    
    private func loadAirQualityData() {
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
        
        openAQClient.fetchLatestAQ(using: latestAQParams) { [weak self] result in
            guard case let .success(latestAQ) = result else {
                isLatestAQLoaded = true
                if allDataIsLoaded { self?.isAQDataLoaded = true }
                return
            }
            self?.latestAQ = latestAQ
            isLatestAQLoaded = true
            if allDataIsLoaded { self?.isAQDataLoaded = true }
        }
        
        let parametersParams = ParameterParameters()
        openAQClient.fetchParameters(using: parametersParams) { [weak self] result in
            guard case let .success(parameters) = result else {
                isParametersInfoLoaded = true
                if allDataIsLoaded { self?.isAQDataLoaded = true }
                return
            }
            self?.parametersInfo = parameters
            isParametersInfoLoaded = true
            if allDataIsLoaded { self?.isAQDataLoaded = true }
        }
    }
    
    private func reloadAirQualityTable() {
        airQualityTable.setNumberOfRows(latestAQ?.results.first?.measurements.count ?? 0, withRowType: AirQualityTableRowController.identifier)
        airQualityLabel.setHidden(airQualityTable.numberOfRows == 0)
        
        for rowIndex in 0..<airQualityTable.numberOfRows {
            let row = airQualityTable.rowController(at: rowIndex) as! AirQualityTableRowController
            guard let aqResult = latestAQ?.results.first?.measurements[rowIndex] else { continue }
            guard let parameterInfo = parametersInfo?.results.filter({ $0.id == aqResult.parameter.rawValue }).first else { continue }
            let measurement = Measurement(value: aqResult.value, unit: aqResult.unit.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if aqResult.unit.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurement)
            let localizedString = String.localizedStringWithFormat(NSLocalizedString("#%@:# %@", comment: "The first token contains the parameter name and the second token contains the value. The # symbol should be placed around the parameter name. An example would be #SO2:# 1 ppm."), parameterInfo.localizedName ?? parameterInfo.name, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: nil)
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            row.statisticLabel.setAttributedText(attributedString)
        }
    }
    
    // MARK: - Water Quality
    
    private func loadWaterQualityData() {
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
        
        nwqpClient.fetchAllResults(using: nwqpParameters) { [weak self] results in
            for result in results {
                guard case let .success(parameter) = result else { continue }
                self?.nwqpResults.append(parameter)
            }
            self?.isNWQPDataLoaded = true
        }
    }
    
    private func reloadWaterQualityTable() {
        waterQualityTable.setNumberOfRows(nwqpResults.count, withRowType: WaterQualityTableRowController.identifier)
        waterQualityLabel.setHidden(waterQualityTable.numberOfRows == 0)
        
        for rowIndex in 0..<waterQualityTable.numberOfRows {
            let row = waterQualityTable.rowController(at: rowIndex) as! WaterQualityTableRowController
            guard let nwqpResult = nwqpResults[rowIndex].organizations?.first?.activity.last?.results.last else { continue }
            guard let measurementInfo = nwqpResult.description.measurement else { continue }
            let measurement = Measurement(value: measurementInfo.value, unit: measurementInfo.unitCode.standardizedUnit)
            let measurementFormatter = MeasurementFormatter()
            if measurementInfo.unitCode.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
            let localizedMeasurement = measurementFormatter.string(from: measurement)
            let localizedString = String.localizedStringWithFormat(NSLocalizedString("#%@:# %@", comment: "The first token contains the parameter name and the second token contains the value. The # symbol should be placed around the parameter name. An example would be #Temperature, water:# 72°F."), nwqpResult.description.characteristicName.rawValue, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: nil)
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            row.statisticLabel.setAttributedText(attributedString)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func contactOfficial() {
        contactOfficialButton.setEnabled(false)
        
        var representativeInfoParams = RepresentativeInfoByAddressParameters()
        representativeInfoParams.address = placemark.addressLines?.joined(separator: " ")
        representativeInfoParams.levels = [.administrativeArea1, .administrativeArea2, .locality, .regional, .special, .subLocality1, .subLocality2]
        representativeInfoParams.roles = [.deputyHeadOfGovernment, .executiveCouncil, .governmentOfficer, .headOfGovernment, .headOfState, .legislatorLowerBody, .legislatorUpperBody]
        civicInformationClient.fetchRepresentativeInfo(using: representativeInfoParams) { result in
            self.contactOfficialButton.setEnabled(true)
            
            if case let .success(representativeInfo) = result {
                func showNoDataAlert() {
                    let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                    let localizedMessage = String.localizedStringWithFormat(NSLocalizedString("%@ doesn't have enough information about government officials for your area. Try using the iPhone app for more options of communication.", comment: "An error message that notifies the user that there isn't enough data about governement officials in a specified region."), appName)
                    let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                    self.presentAlert(withTitle: NSLocalizedString("Oops 😣", comment: "Title of alert control for not enough data error."), message: localizedMessage, preferredStyle: .alert, actions: [cancelAction])
                }
                
                guard let officials = representativeInfo.officials else { showNoDataAlert(); return }
                let filteredOfficials = officials.filter { !($0.phones ?? []).isEmpty }
                guard !filteredOfficials.isEmpty else { showNoDataAlert(); return }
                
                var actions: [WKAlertAction] = []
                
                for official in filteredOfficials {
                    let title = official.name + (official.party != nil ? "" : "")
                    let action = WKAlertAction(title: title, style: .default) {
                        var actions: [WKAlertAction] = []
                        
                        if let phones = official.phones, !phones.isEmpty {
                            for phone in phones {
                                let action = WKAlertAction(title: phone, style: .default) {
                                    var components = URLComponents()
                                    components.scheme = "tel"
                                    components.path = phone
                                    guard let url = components.url else { return }
                                    WKExtension.shared().openSystemURL(url)
                                }
                                actions.append(action)
                            }
                            
                            let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                            actions.append(cancelAction)
                            self.presentAlert(withTitle: NSLocalizedString("Phone", comment: "Tells the user they can call their governement official."), message: NSLocalizedString("Choose a number to call your government official.", comment: "Message that tells the user to select a phone number."), preferredStyle: .actionSheet, actions: actions)
                        }
                    }
                    actions.append(action)
                }
                
                let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                actions.append(cancelAction)
                self.presentAlert(withTitle: NSLocalizedString("Government Officials", comment: "Title for a list of governement officials a user can contact."), message: NSLocalizedString("Choose one of the government officials you wish to contact.", comment: "Message for a list of government officials a user can contact."), preferredStyle: .actionSheet, actions: actions)
            } else {
                let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Aerivo"
                let localizedMessage = String.localizedStringWithFormat(NSLocalizedString("%@ is having trouble getting government representative information. This may be caused by a network error or because the app doesn't have enough information about government officials for your area.", comment: "An error message that notifies the user that there isn't enough data about governement officials in a specified region."), appName)
                let cancelAction = WKAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel alert control action."), style: .cancel) { }
                self.presentAlert(withTitle: NSLocalizedString("Oops 😣", comment: "Title of alert control for network error."), message: localizedMessage, preferredStyle: .alert, actions: [cancelAction])
            }
        }
    }
}
