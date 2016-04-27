//
//  PhoneSupportCategory.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the phone support category class.

@author mohamede1945

@version 1.0
*/
class PhoneSupportCategory {

    /// Represents the items property.
    var items: [PhoneSupport]
    /// Represents the name property.
    var name: String

    /**
    Initialize new instance with name and items.

    - parameter name:  The name parameter.
    - parameter items: The items parameter.

    - returns: The new created instance.
    */
    init(name: String, items: [PhoneSupport]) {
        self.name = name
        self.items = items
    }

    class func fromJson(json: JSON, countryName: String?) -> [PhoneSupportCategory] {
        if json.arrayValue.count > 0 {
            var emails: [PhoneSupport] = []
            
            let maxCategories = 3
            let data = json.arrayValue[0]
            for i in 1...3 {
                let email = data["SD\(i)_Email"].stringValue
                let name = data["SD\(i)_Name"].stringValue
                let phone = data["SD\(i)_Phone"].stringValue
                let desk = data["SD\(i)_Desk"].string ?? ""
                if !email.isEmpty && email != "." {
                    emails.append(PhoneSupport(name: name, text: countryName ?? desk, phone: phone))
                }
            }
            return [PhoneSupportCategory(name: SupportCategoryTitle, items: emails)]
        }
        return []
    }
    
    class func fromSampleJson(json: JSON) -> [PhoneSupportCategory] {
        if let user = AuthenticationUtil.getUserInfo() {
            let emails = json.arrayValue.map { PhoneSupport(json: $0) }
            let categoryNames = Set(emails.map { $0.category })
            
            // split into categories
            var categories: [PhoneSupportCategory] = []
            for catName in categoryNames {
                let name = catName.stringByReplacingOccurrencesOfString("$$FirstName$$", withString: user.firstName)
                
                categories.append(PhoneSupportCategory(name: name, items: emails.filter { $0.category == catName }))
            }
            categories.sortInPlace { $1.name.hasPrefix("Other") }
            categories.first?.items.sortInPlace { $0.name > $1.name }
            categories.last?.items.sortInPlace { $0.name < $1.name }
            return categories
        }
        return []
    }
}

extension PhoneSupportCategory : ArrayDataSourceSection { }

