//
//  DropDownView.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the drop down view class.

@author mohamede1945
@version 1.0
*/
class DropDownView: UIView {

    /// the text field.
    @IBOutlet weak var textField: UITextField!

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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    /**
    Sets up the view.
    */
    func setUp() {
        loadViewFromNib()
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor(r: 191, g: 195, b: 201).CGColor
        layer.borderWidth = 1
    }

    /**
    Loads the view From Nib
    */
    func loadViewFromNib() {
        let nib = UINib(nibName: "DropDownView", bundle: nil)
        let contentView = nib.instantiateWithOwner(self, options: nil).first as! UIView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: [], metrics: nil, views: ["view" : contentView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: [], metrics: nil, views: ["view" : contentView]))
    }

}
