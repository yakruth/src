//
//  InfoCollectionViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/13/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the info collection view cell class.

@author mohamede1945
@version 1.0
*/
class InfoCollectionViewCell: UICollectionViewCell {

    /// Represents the help image.
    @IBOutlet weak var helpImage: UIImageView!
    /// Represents the logo image.
    @IBOutlet weak var logoImage: UIImageView!
    /// Represents the support label.
    @IBOutlet weak var supportLabel: UILabel!
    /// Represents the main label.
    @IBOutlet weak var mainLabel: UILabel!
    /// Represents the sub label.
    @IBOutlet weak var subLabel: UILabel!

    /// Represents the logo height.
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    /// Represents the logo top.
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    /// Represents the sub bottom.
    @IBOutlet weak var subBottom: NSLayoutConstraint!

    /**
    Layout subviews.
    */
    override func layoutSubviews() {
        super.layoutSubviews()

        if UIApplication.sharedApplication().keyWindow?.bounds.width == 320 {
            let expanded = bounds.height > 150
            mainLabel.hidden = !expanded
            subLabel.hidden = !expanded

            if UIApplication.sharedApplication().keyWindow?.bounds.height == 480 {
                logoImage.hidden = !expanded
                supportLabel.hidden = !expanded
            }
        }
    }

    /**
    Awake from nib.
    */
    override func awakeFromNib() {
        super.awakeFromNib()

        supportLabel.text = "portalName".localized

        if UIApplication.sharedApplication().keyWindow?.bounds.height == 480 {
            supportLabel.font = UIFont.thinOfSize(18)
            mainLabel.font = UIFont.lightOfSize(18)
            subLabel.font = UIFont.thinOfSize(15)
            logoHeight.constant = 17
            logoTop.constant = 30
            subBottom.constant = 40
        }
    }
}



extension InfoCollectionViewCell {

    /**
    Configure cell.

    - parameter dictionary: The dictionary
    */
    func configure(dictionary: [String: String]) {
        mainLabel.text = dictionary["main"]?.localized
        subLabel.text = dictionary["sub"]?.localized
        helpImage.image = UIImage(named: dictionary["image"]!)
    }
}