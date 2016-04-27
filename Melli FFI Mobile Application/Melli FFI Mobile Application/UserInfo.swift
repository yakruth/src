//
//  UserInfo.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/// first name
private let kAuthFirstName = "kAuthFirstName"
/// email
private let kAuthEmail = "kAuthEmail"
/// last name
private let kAuthLastName = "kAuthLastName"
/// country
private let kAuthCountry = "kAuthCountry"
// SBG
private let kAuthSBG = "kAuthSBG"
// SBU
private let kAuthSBU = "kAuthSBU"
// SBE
private let kAuthSBE = "kAuthSBE"
// PersonID
private let kAuthPersonId = "kAuthPersonId"

/**
* A representation of the user account data.
* Stores username and authToken. All other fields are optional.
* authToken can be specified later.
*
* @author Alexander Volkov
* @version 1.0
*/
public class UserInfo {
    
    // Email, username, user_id, etc. related to the authentication
    var username: String
    
    /// First name of the user
    var firstName: String = ""

    /// Last name of the user
    var lastName: String = ""
    
    /// Email of the user
    var email: String = ""

    /// Represents the country property.
    var country: String = ""

    var sbg: String = ""

    var sbu: String = ""

    var sbe: String = ""
    
    // Access token obtained from OAuth server
    var accessToken = ""
    
    /// Refresh token obtained from OAuth server
    var refreshToken = ""
    
    var personId = ""
    
    public init(username: String) {
        self.username = username
    }
    
    
    
    /**
    Get full name of the user
    
    - returns: full name
    */
    func getFullName() -> String {
        if firstName == "" {
            return lastName
        }
        return (firstName + " " + lastName).trim()
    }
}

extension UserInfo
{
    func read(json: JSON) {
        firstName = json["UserFirstName"].string ?? ""
        lastName = json["UserLastName"].string ?? ""
        country = json["ProfileCountry"].string ?? ""
        sbg = json["SBG"].string ?? ""
        sbu = json["SBU"].string ?? ""
        sbe = json["SBE"].string ?? ""
        personId = json["PersonID"].string ?? ""
        //personId = "christopherparish"
    }
}

extension UserInfo
{
    func read(userDefaults: NSUserDefaults) {
        if let name = NSUserDefaults.standardUserDefaults().objectForKey(kAuthFirstName) as? String {
            firstName = name
        }
        if let name = NSUserDefaults.standardUserDefaults().objectForKey(kAuthLastName) as? String {
            lastName = name
        }
        if let email = NSUserDefaults.standardUserDefaults().objectForKey(kAuthEmail) as? String {
            self.email = email
        }
        if let country = NSUserDefaults.standardUserDefaults().objectForKey(kAuthCountry) as? String {
            self.country = country
        }
        if let sbg = NSUserDefaults.standardUserDefaults().objectForKey(kAuthSBG) as? String {
            self.sbg = sbg
        }
        if let sbu = NSUserDefaults.standardUserDefaults().objectForKey(kAuthSBU) as? String {
            self.sbu = sbu
        }
        if let sbe = NSUserDefaults.standardUserDefaults().objectForKey(kAuthSBE) as? String {
            self.sbe = sbe
        }
        if let personId = NSUserDefaults.standardUserDefaults().objectForKey(kAuthPersonId) as? String {
            self.personId = personId
        }
    }

    func save(userDefaults: NSUserDefaults) {
        userDefaults.setObject(firstName, forKey: kAuthFirstName)
        userDefaults.setObject(email, forKey: kAuthEmail)
        userDefaults.setObject(lastName, forKey: kAuthLastName)
        userDefaults.setObject(country, forKey: kAuthCountry)
        userDefaults.setObject(sbg, forKey: kAuthSBG)
        userDefaults.setObject(sbu, forKey: kAuthSBU)
        userDefaults.setObject(sbe, forKey: kAuthSBE)
        userDefaults.setObject(personId, forKey: kAuthPersonId)
    }

    class func delete(userDefaults: NSUserDefaults) {
        userDefaults.removeObjectForKey(kAuthFirstName)
        userDefaults.removeObjectForKey(kAuthEmail)
        userDefaults.removeObjectForKey(kAuthLastName)
        userDefaults.removeObjectForKey(kAuthCountry)
        userDefaults.removeObjectForKey(kAuthSBG)
        userDefaults.removeObjectForKey(kAuthSBU)
        userDefaults.removeObjectForKey(kAuthSBE)
        userDefaults.removeObjectForKey(kAuthPersonId)
    }
}