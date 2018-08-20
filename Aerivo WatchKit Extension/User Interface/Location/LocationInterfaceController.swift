//
//  LocationInterfaceController.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/15/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import AerivoKit
import MapboxStatic

class LocationInterfaceController: WKInterfaceController {
    
    static let identifier = "locationIC"
    
    @IBOutlet var locationInterfaceImage: WKInterfaceImage!
    
    @IBOutlet var airQualityLabel: WKInterfaceLabel!
    @IBOutlet var airQualityTable: WKInterfaceTable!
    
    @IBOutlet var waterQualityLabel: WKInterfaceLabel!
    @IBOutlet var waterQualityTable: WKInterfaceTable!
    
    var imageLoadingTask: URLSessionDataTask?
    
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
        setTitle(NSLocalizedString("Location", comment: "Title for a screen that shows the users location and related info."))
        NotificationCenter.default.addObserver(self, selector: #selector(setLocationImage), name: NSNotification.Name(rawValue: "LocationDidChange"), object: nil)
        setLocationImage()
        loadAirQualityData()
        loadWaterQualityData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        // This method is called when watch view controller is visible to user
        LocationManager.shared.locationManager.startUpdatingLocation()
        super.didAppear()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        LocationManager.shared.locationManager.stopUpdatingLocation()
        super.didDeactivate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        imageLoadingTask?.cancel()
        openAQClient.cancelAllPendingRequests()
        nwqpClient.cancelAllPendingRequests()
    }
    
    // MARK: - Location Image
    
    @objc
    private func setLocationImage() {
        let location = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        let camera = SnapshotCamera(lookingAtCenter: location.coordinate, zoomLevel: 12)
        let mapSize = CGSize(width: WKInterfaceDevice.current().screenBounds.width, height: WKInterfaceDevice.current().screenBounds.height * 0.75)
        let options = SnapshotOptions(styleURL: URL(string: "mapbox://styles/mapbox/outdoors-v9")!, camera: camera, size: mapSize)
        let snapshot = Snapshot(options: options)
        imageLoadingTask = snapshot.image { [weak self] image, error in
            self?.locationInterfaceImage.setImage(image)
        }
        imageLoadingTask?.resume()
    }
    
    // MARK: - Air Quality
    
    private func loadAirQualityData() {
        let location = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        let coordinate = location.coordinate
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
            let localizedString = String.localizedStringWithFormat("#%@:# %@", parameterInfo.localizedName ?? parameterInfo.name, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: nil)
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            row.statisticLabel.setAttributedText(attributedString)
        }
    }
    
    // MARK: - Water Quality
    
    private func loadWaterQualityData() {
        let location = LocationManager.shared.locationManager.location ?? CLLocation(latitude: 37.3318, longitude: -122.0054)
        let coordinate = location.coordinate
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
            let localizedString = String.localizedStringWithFormat("#%@:# %@", nwqpResult.description.characteristicName.rawValue, localizedMeasurement)
            let attributedString = NSMutableAttributedString(string: localizedString, attributes: nil)
            attributedString.highlightKeywords(between: "#", with: UIColor(named: "System Green Color")!)
            row.statisticLabel.setAttributedText(attributedString)
        }
    }
}
