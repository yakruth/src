//
//  AppFeedback.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Feedback model
*
* - Author: Nikita Rodin
* :version: 1.1 
*
* changes:
* 1.1:
* - public modifier added to allow to used class in API
* - new comment property and initializer
*/
public class AppFeedbackEntry {
    
    /// title
    var title: String
    /// current answer
    var answer: Int? = nil
    /// text comment
    var comment: String?
    
    /**
    inits entry
    
    - parameter json: JSON object
    
    - returns: initialized entry
    */
    init(json: JSON) {
        self.title = json["title"].stringValue
    }
    
    /**
    inits entry
    
    - parameter title: the question
    
    - returns: initialized entry
    */
    init(title: String) {
        self.title = title
    }
}