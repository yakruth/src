//
//  RoundedLabel.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the rounded label class.

@author mohamede1945
@version 1.0
*/
@IBDesignable
class RoundedLabel: UILabel {

    /// represents the corner radius.
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
}
