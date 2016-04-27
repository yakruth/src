//
//  NewsAlertItem.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* News or Alert item model
*
* - Author: Nikita Rodin
* :version: 1.0
*/
public class NewsAlertItem {
    
    /// title
    var title: String
    /// text
    var text: String
    /// true if news is alert
    var isAlert: Bool
    /// date
    //TODO DELETE THIS
    var date: NSDate
    
    var type: String
    
    var creationDate: NSDate
    var availabilityDate: NSDate
    
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        self.title = json["Summary"].stringValue
        self.text = json["Notes"].stringValue
        

        self.type = json["ContentType"].stringValue
        
        if (self.type == "Alert") {
            self.isAlert = true
        } else {
            self.isAlert = false
        }
        
        
        struct Static {
            static var dateFormatter: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
                }()
        }
        self.creationDate = Static.dateFormatter.dateFromString(json["CreationDate"].stringValue) ?? NSDate()
        self.availabilityDate = Static.dateFormatter.dateFromString(json["AvailabilityDate"].stringValue) ?? NSDate()
        self.date = self.availabilityDate
        
    }
    
}