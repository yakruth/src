//
//  SupportTableHeaderView.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the support table header view class.

@author mohamede1945

@version 1.0
*/
class SupportTableHeaderView: UITableViewHeaderFooterView {

    /// Represents the label property.
    var label = UILabel()

    /**
    Initialize new instance with reuse identifier.

    - parameter reuseIdentifier: The reuse identifier parameter.

    - returns: The new created instance.
    */
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUp()
    }

    /**
    Creates a new view with the passed coder.

    - parameter aDecoder: The a decoder

    - returns: the created new view.
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    /**
    Creates a new view with the passed frame.

    - parameter frame: The frame

    - returns: the created new view.
    */
    /*override init(frame: CGRect?) {
        super.init(frame: frame)
        setUp()
    }*/
    
    /**
    Sets up the view.
    */
    func setUp() {
        contentView.backgroundColor = UIColor(r: 228, g: 229, b: 231)

        label.font = UIFont.lightOfSize(16)
        label.textColor = UIColor.blackColor()

        contentView.addAutoLayoutSubview(label)
        contentView.addParentLeadingConstraint(label, value: 15)
        contentView.addParentBottomConstraint(label, value: 5)
    }

}
