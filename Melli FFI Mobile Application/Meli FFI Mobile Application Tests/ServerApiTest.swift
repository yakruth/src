//
//  ServerApiTest.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 16.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import XCTest
import FFISupportPortal

class ServerApiTest: XCTestCase {
    
    override func setUp() {
        super.setUp()

        var expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__ + "#Login")

        AuthApi().getToken(username: "TMP", password: "TMP", callback: { (userInfo: UserInfo) -> () in

            expectation.fulfill()

        }, errorCallback: getErrorCallbackWithExpectation(expectation))

        waitForExpectationsWithTimeout(15) { (error) -> Void in
            XCTAssertNil(error, "Expectation time out")
        }
    }
    
    /**
    Test status update
    */
    func testUpdateStatus() {
        
        weak var expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__ + "testUpdateStatus")
        
        print("testUpdateStatus: requesting a list of incidents")
        ServerApi.sharedInstance.getIncidentsListParsed(assetCI: "", callback: { (list: [Request]) -> () in
            XCTAssert(list.count > 0, "must be not empty list")
            
            print("testUpdateStatus: updating first incident status")
            for request in list {
                if request.status == Request.Status.Assigned {
                    ServerApi.sharedInstance.updateStatus(request, status: Request.Status.Cancelled, callback: { (request) -> () in
                        print("testUpdateStatus: json=\(request)")
                        expectation.fulfill()
                        
                    }, errorCallback: self.getErrorCallbackWithExpectation(expectation))
                    return
                }
            }
            
        }, errorCallback: self.getErrorCallbackWithExpectation(expectation))
        
        waitForExpectationsWithTimeout(15) { (error) -> Void in
            XCTAssertNil(error, "Should get cached value locally not from the server")
        }
    }
    
    /**
    Test create work info
    */
    func testCreateWorkInfo() {
        
        weak var expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__ + "testCreateWorkInfo")
        
        print("testCreateWorkInfo: requesting a list of incidents")
        ServerApi.sharedInstance.getIncidentsListParsed(assetCI: "", callback: { (list: [Request]) -> () in
            XCTAssert(list.count > 0, "must be not empty list")
            
            print("testCreateWorkInfo: creating work info for first incident request")
            let request = list[0]
            ServerApi.sharedInstance.createWorkInfoParsed(request,
                summary: "Sample summary",
                notes: "sample",
                type: "General Information",
                source: "Other",
                locked: false,
                viewAccess: "Public",
                imageName: "",
                base64String: "",
                callback: { (activity: RequestActivity) -> () in

                    expectation.fulfill()
            }, errorCallback: self.getErrorCallbackWithExpectation(expectation))
            
        }, errorCallback: getErrorCallbackWithExpectation(expectation))
        
        waitForExpectationsWithTimeout(15) { (error) -> Void in
            XCTAssertNil(error, "Should get cached value locally not from the server")
        }
    }
    
    func getErrorCallbackWithExpectation(expectation: XCTestExpectation) -> ((error: RestError, res: RestResponse?) -> ()) {
        return { (error: RestError, res: RestResponse?) -> () in
            print("ERROR: \(error.toString())")
            XCTFail("Error in callback: \(error)")

            expectation.fulfill()
        }

    }

    func testListOfTemplates() {
        var expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__)

//        Logger.loggingEnabled = false

        ServerApi.sharedInstance.listOfTemplatesParsed(callback: { (root) -> () in

            print("templates returned: \(root)")

            expectation.fulfill()
        }, errorCallback: getErrorCallbackWithExpectation(expectation))

        waitForExpectationsWithTimeout(25) { (error) -> Void in
            XCTAssertNil(error, "Expectation time out")
        }
    }
}
