//
//  TodayViewController.swift
//  AirQualityWidget MacOS
//
//  Created by Harish Yerra on 9/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Cocoa
import AerivoKit
import CoreLocation
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding, NSTableViewDataSource, NSTableViewDelegate {
    
    var latestAQ: LatestAQ?
    var parametersInfo: Parameter?
    lazy var openAQClient = OpenAQClient()
    var openAQTasks: [URLSessionDataTask] = []
    
    @IBOutlet weak var tableView: NSTableView!
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    deinit {
        openAQTasks.forEach { if $0.state == .running { $0.cancel() } }
    }
    
    // MARK: - Air Quality
    
    func fetchAirQuality(completionHandler: @escaping (NCUpdateResult) -> Void) {
        guard let location = LocationManager.shared.locationManager.location else {
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return latestAQ?.results.first?.measurements.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: AirQualityTableCellView.identifier), owner: self) as? AirQualityTableCellView else { return nil }
        guard let aqResult = latestAQ?.results.first?.measurements[row] else { return nil }
        guard let parameterInfo = parametersInfo?.results.filter({ $0.id == aqResult.parameter.rawValue }).first else { return nil }
        let measurement = Measurement(value: aqResult.value, unit: aqResult.unit.standardizedUnit)
        let measurementFormatter = MeasurementFormatter()
        if aqResult.unit.isCustomUnit { measurementFormatter.unitOptions = .providedUnit /* Custom dimensions don't support natural scaling at the moment. */ }
        let localizedMeasurement = measurementFormatter.string(from: measurement)
        view.parameter.stringValue = parameterInfo.localizedName ?? parameterInfo.name
        view.value.stringValue = localizedMeasurement
        return view
    }
    
    // MARK: - Table view delegate
    
    // MARK: - Widget providing

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        fetchAirQuality(completionHandler: completionHandler)
    }
    
}
