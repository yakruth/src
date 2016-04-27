//
//  FAQItem.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* FAQ item model
*
* - Author: Nikita Rodin
* :version: 1.1
*
* changes:
* 1.1:
* - public modifier added to allow to used class in API
* - new docId property and fromJSON() method
*/
public class FAQItem {
    
    /// title
    var title: String!
    /// DocID from the FAQ search response
    var docId: String!
    /// the HTML page
    var detail: String!
    
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        self.title = json["title"].stringValue
        self.detail = json["detail"].stringValue
    }
    
    private init() {}
    
    /**
    Parse JSON into FAQItem
    
    - parameter json: JSON from a server response
    
    - returns: new instance
    */
    class func fromJSON(json: JSON) -> FAQItem {
        let faq = FAQItem()
        faq.title = json["ArticleTitle"].stringValue
        faq.docId = json["DocID"].stringValue
        
        return faq
    }
    
}