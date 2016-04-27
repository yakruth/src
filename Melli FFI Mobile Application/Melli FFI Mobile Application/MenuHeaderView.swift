//
//  MenuHeaderView.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the menu header view class.

@author mohamede1945
@version 1.0
*/
class MenuHeaderView: UITableViewHeaderFooterView {

    /// Represents the main label.
    lazy var mainLabel: UILabel =  {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Represents the sub label.
    lazy var subLabel: UILabel =  {
        let label = UILabel()
        label.textColor = UIColor(gray: 95)
        label.font = UIFont.lightOfSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /**
    Set main text and sub text.

    - parameter mainText: The main text
    - parameter subText:  The sub text
    */
    func setMainText(mainText: String, subText: String?) {
        mainLabel.text = mainText
        subLabel.text = subText

        subLabel.removeFromSuperview()
        mainLabel.removeFromSuperview()
        contentView.addSubview(mainLabel)

        addParentLeadingConstraint(mainLabel, value: 20)

        if subText != nil {
            mainLabel.font = UIFont.systemFontOfSize(20)
            contentView.addSubview(subLabel)
            addParentLeadingConstraint(subLabel, value: 20)
            
            addParentTopConstraint(mainLabel, value: 20)
            addSiblingVerticalContiguous(top: mainLabel, bottom: subLabel, value: -5)
        } else {
            mainLabel.font = UIFont.systemFontOfSize(17)
            addParentCenterYConstraint(mainLabel)
        }
        contentView.backgroundColor = UIColor(gray: 44)
    }
}
