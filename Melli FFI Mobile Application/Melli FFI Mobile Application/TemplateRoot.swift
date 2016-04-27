//
//  TemplateRoot.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/20/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
Represents the template root class.

@author mohamede1945

@version 1.0
*/
public class TemplateRoot : TemplateNode {

    /**
    Initialize new instance.

    - returns: The new created instance.
    */
    init() {
        super.init(name: "")
    }

    /**
    Add name to the names.

    - parameter branchNames: The branch names parameter.
    */
    override func addName(inout branchNames: [String]) {
        // does nothing
    }
}