//
//  BackendService.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/16/15.
//  Updated by Nikita Rodin on 8/06/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
A mock class for mocking backend services

- Author:  mohamede1945
:version: 1.0
*/
class BackendService {

    /// The list of requests.
    static var requests: [Request]?

    /**
    Gets a data source from plist file.

    - parameter name: the data source name
    - returns: returns the data source value for the name inside service dictionary.
    */
    func getDataSource(name: String) -> AnyObject {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("DataSource", ofType: "plist")
        let dataSources = NSDictionary(contentsOfFile: path!)!

        return dataSources[name]!
    }

    /**
    Gets login help information

    - returns: the help information.
    */
    func getLoginHelp() -> [[String: String]] {
        return getDataSource("loginHelp") as! [[String : String]]
    }

    /**
    Gets user information.

    - returns: the user information.
    */
    func getUserInfo() -> [String: String] {
        return getDataSource("userInfo") as! [String: String]
    }

    /**
    Get emails from json.

    - returns: the emails from JSON file.
    */
    func getEmailsFromJSON() -> [EmailSupportCategory] {
        
        if let user = AuthenticationUtil.getUserInfo() {
            let path = NSBundle(forClass: self.dynamicType).pathForResource("ServiceDeskInfo", ofType: "json")
            let json = JSON(data: NSData(contentsOfFile: path!)!)
            
            let emails = json.arrayValue.map { EmailSupport(json: $0) }
            let categoryNames = Set(emails.map { $0.category })
            
            // split into categories
            var categories: [EmailSupportCategory] = []
            for catName in categoryNames {
                let name = catName.stringByReplacingOccurrencesOfString("$$FirstName$$", withString: user.firstName)
                
                categories.append(EmailSupportCategory(name: name, items: emails.filter { $0.category == catName }))
            }
            categories.sortInPlace { $1.name.hasPrefix("Other") }
            categories.first?.items.sortInPlace { $0.name > $1.name }
            categories.last?.items.sortInPlace { $0.name < $1.name }
            
            return categories
        }
        
        return []
    }

    /**
    Get phones from json.

    - returns: The phones from JSON file.
    */
    func getPhonesFromJSON() -> [PhoneSupportCategory] {

        if let user = AuthenticationUtil.getUserInfo() {
            let path = NSBundle(forClass: self.dynamicType).pathForResource("ServiceDeskInfo", ofType: "json")
            let json = JSON(data: NSData(contentsOfFile: path!)!)
            
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


    /**
    searches for FAQ containing the phrase
    
    - parameter phrase: phrase to search
    
    - returns: matching items
    */
    func searchFAQ(phrase: String) -> [FAQItem] {
        /// all items
        struct Static {
            static var allItems: [FAQItem] = []
            static var once: dispatch_once_t = 0
        }
        dispatch_once(&Static.once) {
            let json = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("FAQItems", ofType: "json")!)!)
            Static.allItems = json.arrayValue.map({ FAQItem(json: $0) })
            // fill with our html if detail is empty
            for item in Static.allItems {
                if item.detail.isEmpty {
                    item.detail = (try? String(contentsOfFile: NSBundle.mainBundle().pathForResource("KBA_TEST", ofType: "html")!, encoding: NSISOLatin1StringEncoding)) ?? ""
                }
            }
        }
        
        return Static.allItems.filter { $0.title.rangeOfString(phrase, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil }
    }
    
}