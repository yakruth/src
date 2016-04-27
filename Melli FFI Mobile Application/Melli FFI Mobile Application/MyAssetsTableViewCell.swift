//
//  MyAssetsTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 1/6/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

protocol MyAssetsTableViewCellDelegate : class {
    /**
     request cell tapped
     
     - parameter MyAssetsTableViewCell: The request table view cell
     */
    func assetsTableViewCellActionTapped(assetsTableViewCell: MyAssetsTableViewCell)
    
    /**
     button tapped
    */
    
    func templateButtonTapped(assetsTableViewCell: MyAssetsTableViewCell, sender: AnyObject)
}


class MyAssetsTableViewCell: ActionableTableViewCell {
    
    /// Represents the delegate.
    weak var delegate: MyAssetsTableViewCellDelegate?

    /// Represents the main label.
    @IBOutlet weak var mainLabel: UILabel!
    /// Represents the sub label.
    @IBOutlet weak var subLabel: UILabel!
    
    var assetEntity = Assets()
}


extension MyAssetsTableViewCell {
    
    /**
     Configure the cell.
     
     - parameter entity: The entity
     */
    func configure(entity: Assets) {
        
        assetEntity = entity
        
        subLabel.text = entity.item
        subLabel.textColor = UIColor.blackColor()
                
        let number = NSMutableAttributedString(string: entity.ciName /*entity.incidentId*/,
            attributes: [NSForegroundColorAttributeName: UIColor(r: 74, g: 143, b: 222)])
//        let separator = NSAttributedString(string: "  |  ",
//            attributes: [NSForegroundColorAttributeName: UIColor(r: 137, g: 153, b: 153)])
//        let summary = NSAttributedString(string: entity.summary,
//            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
//        number.appendAttributedString(separator)
//        number.appendAttributedString(summary)
        mainLabel.attributedText = number
    }

    /**
    */
    @IBAction func buttonAction(sender: AnyObject)  {
        delegate?.templateButtonTapped(self, sender: sender)
    }
    
    /**
     Action tapped
     */
    func actionTapped() {
        resetScrollView(true)
        delegate?.assetsTableViewCellActionTapped(self)
    }

}