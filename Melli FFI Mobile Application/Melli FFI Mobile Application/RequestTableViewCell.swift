//
//  RequestTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/16/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

protocol RequestTableViewCellDelegate : class {
    /**
    request cell tapped

    - parameter requestTableViewCell: The request table view cell
    */
    func requestTableViewCellActionTapped(requestTableViewCell: RequestTableViewCell)
}

class RequestTableViewCell: ActionableTableViewCell {

    /// Represents the delegate.
    weak var delegate: RequestTableViewCellDelegate?

    /// Represents the main label.
    @IBOutlet weak var mainLabel: UILabel!
    /// Represents the sub label.
    @IBOutlet weak var subLabel: UILabel!
    /// Represents the color view.
    @IBOutlet weak var colorView: UIView!
}


extension RequestTableViewCell {

    /**
    Configure the cell.

    - parameter entity: The entity
    */
    func configure(entity: Request) {
        let action = entity.status.nextStatus()
        if let action = action {
            let buttons = setActions([(action: action.action, color: action.color, width: 75)])
            buttons.first?.addTarget(self, action: "actionTapped", forControlEvents: .TouchUpInside)
        }

        subLabel.text = entity.summary
        subLabel.textColor = UIColor(r: 32, g: 41, b: 58)

        //cparish updated
        //colorView.backgroundColor = entity.status.getColor()
        colorView.backgroundColor = entity.status.getBackgroundColor()

        let number = NSMutableAttributedString(string: entity.incidentId,
            attributes: [NSForegroundColorAttributeName: UIColor(r: 74, g: 143, b: 222)])
        let separator = NSAttributedString(string: "  |  ",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 137, g: 153, b: 153)])
        let summary = NSAttributedString(string: entity.status.rawValue.localized,
            attributes: [NSForegroundColorAttributeName: entity.status.getColor(),
            NSFontAttributeName: UIFont.mediumOfSize(15)])
        number.appendAttributedString(separator)
        number.appendAttributedString(summary)
        mainLabel.attributedText = number
    }

    /**
    Action tapped
    */
    func actionTapped() {
        resetScrollView(true)
        delegate?.requestTableViewCellActionTapped(self)
    }
}