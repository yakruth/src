//
//  Subscription.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Subscription model
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class Subscription {
    
    /// title
    var title: String
    /// current value
    var value: Bool
    
    var userChanged: Bool
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        self.title = json["ContentLabel"].stringValue
        
        //var SubscriptionFlag = json["SubscriptionFlag"].stringValue
        let SubscriptionFlag = "No"
 
        if ("Yes" == SubscriptionFlag) {
            self.value = true;
        } else {
            self.value = false;
        }

        
        self.userChanged = false;
    }
    
    class func listFromJson(json: JSON) -> [Subscription] {
        var subscriptionsItems = [Subscription]()
        
        for item in json.arrayValue {
            subscriptionsItems.append(Subscription(json: item))
        }
        
        return subscriptionsItems
    }
}