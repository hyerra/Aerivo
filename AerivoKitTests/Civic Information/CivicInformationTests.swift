//
//  CivicInformationTests.swift
//  AerivoKitTests
//
//  Created by Harish Yerra on 7/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import XCTest
@testable import AerivoKit

class CivicInformationTests: XCTestCase {
    
    var client: CivicInformationClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        client = CivicInformationClient()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        client = nil
        super.tearDown()
    }
    
    func testFetchingRepresentativeInfoByAddress() {
        var params = RepresentativeInfoByAddressParameters()
        params.address = "6904 L Avenue Pl, Kearney, NE 68847"
        
        let resultsExpectation = expectation(description: "Fetching representatives should return accurate results.")
        
        client.fetchRepresentativeInfo(using: params) { result in
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
