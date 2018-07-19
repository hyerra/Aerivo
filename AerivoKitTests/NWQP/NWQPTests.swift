//
//  NWQPTests.swift
//  AerivoKitTests
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import XCTest
@testable import AerivoKit

class NWQPTests: XCTestCase {
    
    var client: NWQPClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        client = NWQPClient()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        client = nil
    }
    
    func testFetchingStations() {
        var params = NWQPParameters()
        params.stateCode = "US:10"
        params.zip = .no
        
        let stationsExpectation = expectation(description: "Fetching stations should succeed.")
        
        client.fetchStations(using: params) { result in
            switch result {
            case .success:
                stationsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchingWaterTemperature() {
        var params = NWQPParameters()
        var startDateComponents = DateComponents()
        startDateComponents.month = 07
        startDateComponents.day = 05
        startDateComponents.year = 2018
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        var endDateComponents = DateComponents()
        endDateComponents.month = 07
        endDateComponents.day = 07
        endDateComponents.year = 2018
        let endDate = Calendar(identifier: .gregorian).date(from: endDateComponents)
        
        params.startDate = startDate
        params.endDate = endDate
        params.stateCode = "US:06"
        params.characteristicName = .waterTemperature
        params.zip = .no
                
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(result.organization.count, 1, "The amount of organizations is incorrect.")
                XCTAssertEqual(result.organization.first!.description.id, "USGS-NV", "The organization's id is incorrect.")
                XCTAssertEqual(result.organization.first!.description.formalName, "USGS Nevada Water Science Center", "The organization's formal name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.count, 2, "The amount of activity entries is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.id, "nwisnv.01.01800393", "The activity id is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.typeCode, "Sample-Routine", "The activity type code is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.mediaName, "Water", "The media name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.mediaSubdivisionName, "Surface Water", "The media subdivision name is incorrect.")
                
                var dateComps = DateComponents()
                dateComps.month = 07
                dateComps.day = 06
                dateComps.year = 2018
                let date = Calendar(identifier: .gregorian).date(from: dateComps)
                
                XCTAssertEqual(result.organization.first!.activity.first!.description.startDate, date!, "The start date is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.conductionOrganization, "USGS - Nevada Water Science Center", "The conducting organization name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.monitoringLocationID, "USGS-10336610", "The monitoring location identifier is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.hydrolicCondition, "Stable, low stage", "The hydrolic condition is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.description.hydrolicEvent, "Routine sample", "The hydrolic event is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.sample.collectionMethod.id, "10", "The collection method id is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.sample.collectionMethod.identifierContext, "USGS parameter code 82398", "The collection method identifier context is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.sample.collectionMethod.name, "Equal width increment (ewi)", "The collection method name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.sample.equipmentName, "US DH-81", "The collection method equipment name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.characteristicName, NWQPResult.Organization.Activity.Result.Description.CharacteristicName.waterTemperature, "The characteristic name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.measurement.value, 15.0, "The result value is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.measurement.unitCode, .celsius, "The unit is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.statusID, "Preliminary", "The status id is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.valueType, "Actual", "The value type is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.description.usgspCode, "00010", "The USGSP code is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.analyticalMethod.id, "THM02", "The USGSP code is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.analyticalMethod.identifierContext, "USGS", "The analytical method identifier context is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.analyticalMethod.name, "Temperature, water, liq-in-glass", "The analytical method name is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.analyticalMethod.descriptionText, "USGS National Field Manual, Chapter A6.1", "The analytical method identifier description text is incorrect.")
                XCTAssertEqual(result.organization.first!.activity.first!.result.labInformation.name, "U.S. Geological Survey-Water Resources Discipline", "The laboratory name is incorrect.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
}
