//
//  ValidationUtils.swift
//  Melli FFI Mobile Application
//
//  Created by Alexander Volkov on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Validation utilities. Helps to check parameters in service methods before sending HTTP request.
*
* @author Alexander Volkov
* @version 1.0
*/
class ValidationUtils {
    
    /**
    Check 'value' if it's not nil and callback failure if it is.
    
    - parameter value:   the value to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if string is not empty
    */
    class func validateNil(value: AnyObject?, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if value == nil {
            failure?(RestError.errorWithMessage(NSLocalizedString("NIL_VALUE",comment:"Nil Value")), nil)
            return false
        }
        return true
    }
    
    /**
    Check URL for correctness and callback failure if it's not.
    
    - parameter url:     the URL to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if URL is correct
    */
    class func validateUrl(url: String?, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if url == nil || url == "" {
            failure?(RestError.errorWithMessage(NSLocalizedString("EMPTY_URL",comment:"Empty URL")), nil)
            return false
        }
        if !url!.hasPrefix("http") {
            failure?(RestError.errorWithMessage(NSLocalizedString("URL_SHOULD_START_WITH_HTTP",comment:"URL should start with \"http\"")), nil)
            return false
        }
        return true
    }
    
    /**
    Check 'string' if it's correct ID.
    Delegates validation to two other methods.
    
    - parameter id:      the id string to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if string is not empty
    */
    class func validateId(id: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !ValidationUtils.validateStringNotEmpty(id, failure) { return false }
        if id.isNumber() && !ValidationUtils.validatePositiveNumber(id, failure) { return false }
        return true
    }
    
    /**
    Check 'string' if it's empty and callback failure if it is.
    
    - parameter string:  the string to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if string is not empty
    */
    class func validateStringNotEmpty(string: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if string.isEmpty {
            failure?(RestError.errorWithMessage(NSLocalizedString("EMPTY_STRING",comment:"Empty string")), nil)
            return false
        }
        return true
    }
    
    /**
    Check if the string is positive number and if not, then callback failure and return false.
    
    - parameter numberString: the string to check
    - parameter failure:      the closure to invoke if validation fails
    
    - returns: true if given string is positive number
    */
    class func validatePositiveNumber(numberString: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !numberString.isPositiveNumber() {
            failure?(RestError.errorWithMessage(String.localizedStringWithFormat(NSLocalizedString("INCORRECT_NUMBER_FORMAT",comment:"Incorrect Number: %s"),numberString)), nil)
            return false
        }
        return true
    }
    
    /**
    Check if the string represents email
    
    - parameter email:   the text to validate
    - parameter failure: the closure to invoke if validation fails

    - returns: true if given string is email
    */
    class func validateEmail(email: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if email.trim() ≈ emailPattern {
            return true
        }
        failure?(RestError.errorWithMessage(String.localizedStringWithFormat(NSLocalizedString("INCORRECT_EMAIL_FORMAT",comment:"Incorrect email format: %s"), email)), nil)
        return false
    }
    
}