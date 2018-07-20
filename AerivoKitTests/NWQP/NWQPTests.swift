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
    
    func testFetchingBeckBioticIndex() {
        var params = NWQPParameters()
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.stateCode = "US:10"
        params.characteristicName = .beckBioticIndex
        params.zip = .no
        
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchingBrillouinTaxonomicDiversityIndex() {
        var params = NWQPParameters()
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.characteristicName = .brillouinTaxonomicDiversityIndex
        params.zip = .no
        
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchingDissolvedOxygen() {
        var params = NWQPParameters()
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.characteristicName = .dissolvedOxygen
        params.zip = .no
        params.stateCode = "US:06"
        
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
                resultsExpectation.fulfill()
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
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.stateCode = "US:06"
        params.characteristicName = .waterTemperature
        params.zip = .no
                
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchingTurbiditySeverity() {
        var params = NWQPParameters()
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.characteristicName = .turbiditySeverity
        params.zip = .no
        
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
                resultsExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Error: \(error!)")
        }
    }
    
    func testFetchingHydrocarbons() {
        var params = NWQPParameters()
        
        let startDateComponents = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        let startDate = Calendar(identifier: .gregorian).date(from: startDateComponents)
        
        params.startDate = startDate
        params.characteristicName = .hydrocarbons
        params.zip = .no
        
        let resultsExpectation = expectation(description: "Fetching results should return accurate results.")
        
        client.fetchResults(using: params) { result in
            switch result {
            case .success:
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
