//
//  TodayViewController.swift
//  AirQualityWidget
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import CoreLocation
import AerivoKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    
    var latestAQ: LatestAQ?
    var parametersInfo: Parameter?
    lazy var openAQClient = OpenAQClient()
    var openAQTasks: [URLSessionDataTask] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        tableView.separatorEffect = UIBlurEffect(style: .extraLight)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    deinit {
        openAQTasks.forEach { if $0.state == .running { $0.cancel() } }
    }
    
    // MARK: - Air Quality
    
    func fetchAirQuality(completionHandler: @escaping (NCUpdateResult) -> Void) {
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse, let location = CLLocationManager().location else {
            completionHandler(.failed)
            latestAQ = nil
            return
        }
        
        var latestAQParams = LatestAQParameters()
        latestAQParams.coordinates = location.coordinate
        latestAQParams.radius = 800000
        latestAQParams.orderBy = .distance
        latestAQParams.limit = 1
        
        var isLatestAQLoaded = false
        var isParametersInfoLoaded = false
        
        var allDataIsLoaded: Bool {
            return isLatestAQLoaded && isParametersInfoLoaded
        }
        
        let latestAQTask = openAQClient.fetchLatestAQ(using: latestAQParams) { [weak self] result in
            guard case let .success(latestAQ) = result else { return }
            self?.latestAQ = latestAQ
            isLatestAQLoaded = true
            if allDataIsLoaded { self?.tableView.reloadData(); completionHandler(.newData) }
        }
        openAQTasks.append(latestAQTask)
        
        let parametersParams = ParameterParameters()
        let parametersTask = openAQClient.fetchParameters(using: parametersParams) { [weak self] result in
            guard case let .success(parameters) = result else { return }
            self?.parametersInfo = parameters
            isParametersInfoLoaded = true
            if allDataIsLoaded { self?.tableView.reloadData(); completionHandler(.newData) }
        }
        openAQTasks.append(parametersTask)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard latestAQ?.results.first?.measurements.count != nil else { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestAQ?.results.first?.measurements.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AirQualityTableViewCell.identifier, for: indexPath) as! AirQualityTableViewCell
        guard let aqResult = latestAQ?.results.first?.measurements[indexPath.row] else { return cell }
        guard let parameterInfo = parametersInfo?.results.filter({ $0.id == aqResult.parameter.rawValue }).first else { return cell }
        let measurement = Measurement(value: aqResult.value, unit: aqResult.unit.standardizedUnit)
        let measurementFormatter = MeasurementFormatter()
        if aqResult.unit.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
        let localizedMeasurement = measurementFormatter.string(from: measurement)
        cell.parameter.text = parameterInfo.localizedName ?? parameterInfo.name
        cell.value.text = localizedMeasurement
        return cell
    }
    
    // MARK: - Table view delegate
    
    // MARK: - Widget providing
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? tableView.contentSize : maxSize
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        fetchAirQuality(completionHandler: completionHandler)
    }
    
}
