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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchingWaterTemperature() {
        var params = NWQPParameters()
        let components = Calendar(identifier: .gregorian).dateComponents([.month, .year], from: Date())
        params.startDate = Calendar(identifier: .gregorian).date(from: components)
        params.stateCode = "US:06"
        params.characteristicName = "Temperature, water"
        params.zip = false
        
        //let endpoint = NWQPEndpoint.results(parameters: params)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
