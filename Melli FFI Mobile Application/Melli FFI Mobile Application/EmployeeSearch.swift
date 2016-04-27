//
//  EmployeeSearch.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/4/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//


import UIKit

public class EmployeeSearch : NSObject {
    
    /// Represents first name
    var fullName : String = ""
    /// Represents first name
    var eid : String = ""
    /// Represents first name
    var deptName : String = ""
    /// Represents first name
    var personID : String = ""
    
    /**
     Initialize new instance of the class
     
     - returns: the created new instance
     */
    override init() {
    }
    
    /**
     Parse JSON data
     
     - parameter json: JSON data
     
     - returns: EmployeeSearch instance
     */
    class func fromJSON(json: JSON) -> EmployeeSearch {
        let employeeSearch = EmployeeSearch()
        employeeSearch.fullName = json["FullName"].stringValue
        employeeSearch.eid = json["EID"].stringValue
        employeeSearch.deptName = json["SBG"].stringValue
        employeeSearch.personID = json["PersonID"].stringValue

        return employeeSearch
    }

}

