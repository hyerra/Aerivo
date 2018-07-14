//
//  OpenAQTests.swift
//  AerivoKitTests
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import XCTest
@testable import AerivoKit

class OpenAQTests: XCTestCase {
    
    var client: OpenAQClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        client = OpenAQClient()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        client = nil
        super.tearDown()
    }
    
    func testFetchCities() {
        let resultsExpectation = expectation(description: "Fetching cities should return results.")
        
        let params = CitiesParameters()
        client.fetchCities(using: params) { result in
            switch result {
            case .success(let city):
                XCTAssertNotEqual(city.results.count, 0, "No cities were returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchCountries() {
        let resultsExpectation = expectation(description: "Fetching countries should return results.")
        
        let params = CountriesParameters()
        client.fetchCountries(using: params) { result in
            switch result {
            case .success(let country):
                XCTAssertNotEqual(country.results.count, 0, "No countries were returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testRetreivingFetches() {
        let resultsExpectation = expectation(description: "Retreiving fetches should return results.")
        
        let params = FetchParameters()
        client.retrieveFetches(using: params) { result in
            switch result {
            case .success(let fetch):
                XCTAssertNotEqual(fetch.results.count, 0, "No fetches were returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchLatestAQ() {
        let resultsExpectation = expectation(description: "Fetching latest air quality should return results.")
        
        let params = LatestAQParameters()
        client.fetchLatestAQ(using: params) { result in
            switch result {
            case .success(let latestAQ):
                XCTAssertNotEqual(latestAQ.results.count, 0, "No air quality data was returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchLocations() {
        let resultsExpectation = expectation(description: "Fetching locations should return results.")
        
        let params = LocationsParameters()
        client.fetchLocations(using: params) { result in
            switch result {
            case .success(let locations):
                XCTAssertNotEqual(locations.results.count, 0, "No location data was returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testMeasurementsInfo() {
        let resultsExpectation = expectation(description: "Fetching measurement info should return results.")
        
        let params = MeasurementsParameters()
        client.fetchMeasurementsInfo(using: params) { result in
            switch result {
            case .success(let measurementsInfo):
                XCTAssertNotEqual(measurementsInfo.results.count, 0, "No measurement info was returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchParameters() {
        let resultsExpectation = expectation(description: "Fetching parameters should return results.")
        
        let params = ParameterParameters()
        client.fetchParameters(using: params) { result in
            switch result {
            case .success(let measurementsInfo):
                XCTAssertNotEqual(measurementsInfo.results.count, 0, "No parameter data was returned.")
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchSources() {
        let resultsExpectation = expectation(description: "Fetching sources should return results.")
        
        let params = SourcesParameters()
        client.fetchSources(using: params) { result in
            switch result {
            case .success(let measurementsInfo):
                XCTAssertNotEqual(measurementsInfo.results.count, 0, "No sources data was returned.")
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
