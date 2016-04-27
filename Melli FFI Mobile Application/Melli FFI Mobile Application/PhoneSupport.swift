//
//  PhoneSupport.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the phone support class.

@author mohamede1945

@version 1.0
*/
class PhoneSupport {

    /// Represents the name property.
    let name: String
    /// Represents the text property.
    let text: String
    /// Represents the phone property.
    let phone: String
    /// Represents the category property.
    var category: String = ""


    init(name: String, text: String, phone: String) {
        self.name = name
        self.text = text
        self.phone = phone
    }

    /**
    * Instantiate the instance using the passed dictionary values to set the properties values
    */
    init(fromDictionary dictionary: NSDictionary){
        name = dictionary["name"] as! String
        text = dictionary["text"] as! String
        phone = dictionary["phone"] as! String
    }

    /**
    Gets the plain phone number.

    - returns: The plain phone number.
    */
    func phoneNumber() -> String {
        let replaceStrings = [")", "(", ",", "-", " "]
        var phone = self.phone
        for value in replaceStrings {
            phone = phone.stringByReplacingOccurrencesOfString(value, withString: "")
        }
        return phone
    }
    
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        name = json["name"].stringValue
        text = json["text"].stringValue
        phone = json["phone"].stringValue
        category = json["category"].stringValue
    }
}