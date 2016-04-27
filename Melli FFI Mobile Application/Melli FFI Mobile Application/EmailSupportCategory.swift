//
//  EmailSupportCategory.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

let SupportCategoryTitle = "MobileApp here is your Primary Support Desk"

/**
Represents the email support category class.

@author mohamede1945

@version 1.0
*/
class EmailSupportCategory {
    
    /// Represents the items property.
    var items: [EmailSupport]
    /// Represents the name property.
    var name: String

    /**
    Initialize new instance with name and items.

    - parameter name:  The name parameter.
    - parameter items: The items parameter.

    - returns: The new created instance.
    */
    init(name: String, items: [EmailSupport]) {
        self.name = name
        self.items = items
    }
}

extension EmailSupportCategory : ArrayDataSourceSection {
    
    class func fromJson(json: JSON, countryName: String?) -> [EmailSupportCategory] {
        if json.arrayValue.count > 0 {
            var emails: [EmailSupport] = []
            
            let maxCategories = 3
            let data = json.arrayValue[0]
            for i in 1...3 {
                let email = data["SD\(i)_Email"].stringValue
                let name = data["SD\(i)_Name"].stringValue
                let phone = data["SD\(i)_Phone"].stringValue
                let desk = data["SD\(i)_Desk"].string ?? ""
                if !email.isEmpty && email != "." {
                    emails.append(EmailSupport(name: name, text: countryName ?? desk, email: email, subject: ""))
                }
            }
            return [EmailSupportCategory(name: SupportCategoryTitle, items: emails)]
        }
        return []
    }
    
}