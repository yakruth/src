//
//  TokenStorageTest.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import XCTest
import FFISupportPortal

class TokenStorageTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    Test saving and restoring a token
    */
    func testTokenSave() {
        let token1 = "1234567890"
        TokenStorage.saveToken(token1, key: TokenStorage.kAccessToken)
        let restoredToken1 = TokenStorage.getToken(TokenStorage.kAccessToken)
        XCTAssert(token1 == restoredToken1, "restored token is not equal to original")
        
        let token2 = "abcdefgh"
        TokenStorage.saveToken(token2, key: TokenStorage.kRefreshToken)
        let restoredToken2 = TokenStorage.getToken(TokenStorage.kRefreshToken)
        XCTAssert(token2 == restoredToken2, "restored token is not equal to original")
    }
    

}
