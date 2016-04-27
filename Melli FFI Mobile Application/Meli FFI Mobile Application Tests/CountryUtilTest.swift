//
//  CountryUtilTest.swift
//  Meli FFI Mobile Application
//
//  Created by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import XCTest
import FFISupportPortal

/**
* Test for CountryUtil
*
* @author TCASSEMBLER
* @version 1.0
*/
class CountryUtilTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Tests getCurrentCountryCode method.
    WARNING! You need to test on a real device to get a location. Even on a real device a location there is a possibility that a location cannot be defined.
    */
    func testCountryUtil() {
        var expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__)

        let countryManager = CountryUtil()

        // Get country code
        countryManager.getCurrentCountryCodeWithSuccess({ (countryCode: String) -> () in
            print("Current country code: \(countryCode)")
            expectation.fulfill()

            }, failure: { (error) -> () in
                XCTFail("Shouldn't fail")
                expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(15) { (error) -> Void in
            XCTAssertNil(error, "Expectation time out")
        }
    }

    /**
    Tests printAllCountries method
    */
    func testPrintAllCountries() {
        let path = NSBundle.mainBundle().pathForResource("Countries", ofType: "json")
        let json = JSON(data: NSData(contentsOfFile: path!)!)

        let countryManager = CountryUtil()

        let locales = countryManager.locales()
        countries: for c in json.arrayValue {
            for l in locales {
                if l.countryName == c.stringValue {
                    print("\(c) \(l.countryCode)")
                    continue countries
                }
            }
            print("\(c) ------- ")
        }

        countryManager.printAllCountries()
    }
}
