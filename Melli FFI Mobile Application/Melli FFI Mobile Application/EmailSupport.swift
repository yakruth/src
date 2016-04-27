//
//  EmailSupport.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the email support class.

@author mohamede1945

@version 1.0
*/
class EmailSupport {

    /// Represents the name property.
    var name: String
    /// Represents the text property.
    var text: String
    /// Represents the email property.
    var email: String
    /// Represents the subject property.
    var subject: String
    /// Represents the category property.
    var category: String = ""


    init(name: String, text: String, email: String, subject: String) {
        self.name = name
        self.text = text
        self.email = email
        self.subject = subject
    }

    /**
    * Instantiate the instance using the passed dictionary values to set the properties values
    */
    init(fromDictionary dictionary: NSDictionary){
        name = dictionary["name"] as! String
        text = dictionary["text"] as! String
        email = dictionary["email"] as! String
        subject = dictionary["subject"] as! String
    }
    
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        name = json["name"].stringValue
        text = json["text"].stringValue
        email = json["email"].stringValue
        subject = json["subject"].stringValue
        category = json["category"].stringValue
    }
}
