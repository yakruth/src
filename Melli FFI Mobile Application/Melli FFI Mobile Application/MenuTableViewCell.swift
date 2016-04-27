//
//  MenuTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the menu table view cell class.

@author mohamede1945
@version 1.0
*/
class MenuTableViewCell: UITableViewCell {

    /// Represents the icon image.
    @IBOutlet weak var iconImage: UIImageView!
    /// Represents the name label.
    @IBOutlet weak var nameLabel: UILabel!
    /// Represents the background view.
    @IBOutlet weak var background: UIView!
    
    /// flag: true - the menu item is disabled, false - enabled
    var isDisabled: Bool = false {
        didSet {
            color = isDisabled ? UIColor(gray: 101) : UIColor.whiteColor()
        }
    }
    
    var color = UIColor.whiteColor()

    /**
    Set selected state.

    - parameter selected: The selected
    - parameter animated: The animated
    */
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        nameLabel.textColor = color
        iconImage.tintColor = color
        background.hidden = true
    }

    /**
    Set hightlighted state.

    - parameter highlighted: The highlighted
    - parameter animated:    The animated
    */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        nameLabel.textColor = color
        iconImage.tintColor = color
        background.hidden = !highlighted
        if !highlighted && selected {
            setSelected(selected, animated: animated)
        }
    }

}


extension MenuTableViewCell {
    /**
    Configure the cell.

    - parameter menu: The menu
    */
    func configure(menu: MenuViewController.Menu) {
        nameLabel.text = menu.name
        iconImage.image = UIImage(named: menu.imageName)?.imageWithRenderingMode(.AlwaysTemplate)
        isDisabled = menu.controllerName == DisabledControllerName
    }
}