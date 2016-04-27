//
//  RestResponse.swift
//  Melli FFI Mobile Application
//
//  Created by Alexander Volkov on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Object representation of a HTTP Response.
*
* @author Alexander Volkov
* @version 1.0
*/
public class RestResponse {
    
    // HTTP headers
    public var headers: Dictionary<String,String>?
    
    // Parsed response body
    public var responseObject: AnyObject?
    
    // an occurred error during the HTTP request
    public var error: NSError?
    
    // the HTTP result code
    public var statusCode: Int?
    
    // the Mime type of the received content
    public var mimeType: String?
    
    // the requested URL
    public var URL: NSURL?
    
    init(responseObject : AnyObject?) {
        self.responseObject = responseObject;
    }
    
}