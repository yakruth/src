//
//  AssetDetailTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 1/7/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit


class AssetDetailTableViewCell: UITableViewCell {
    
    /**
     *  The Main Label.
     */
    @IBOutlet weak var mainLabel: UILabel!
    
    /**
     *  The sub Label.
     */
    @IBOutlet weak var subLabel: UILabel!

}

extension AssetDetailTableViewCell {
    
    /**
     Configure the cell.
     
     - parameter entity: The entity
     */
    func configure(entity: Request) {
        
        //***************
        let number = NSMutableAttributedString(string: entity.incidentId,
            attributes: [NSForegroundColorAttributeName: UIColor(r: 74, g: 143, b: 222)])
        let separator = NSAttributedString(string: "  |  ",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 137, g: 153, b: 153)])
        let summary = NSAttributedString(string: entity.status.rawValue.localized,
            attributes: [NSForegroundColorAttributeName: entity.status.getColor(),
                        NSFontAttributeName: UIFont.mediumOfSize(15)])
        number.appendAttributedString(separator)
        number.appendAttributedString(summary)
        //***************
        self.mainLabel.attributedText = number
        
        self.subLabel.text = entity.summary
        self.subLabel.textColor = UIColor(r: 32, g: 41, b: 58)
    }
}