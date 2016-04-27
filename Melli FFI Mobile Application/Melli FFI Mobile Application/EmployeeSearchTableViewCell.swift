//
//  EmployeeSearchTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/4/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit


class EmployeeSearchTableViewCell: UITableViewCell {
    
    /// Represents the main label.
    @IBOutlet weak var mainLabel: UILabel!

}


extension EmployeeSearchTableViewCell {
    
    /**
     Configure the cell.
     
     - parameter entity: The entity
     */
    func configure(entity: EmployeeSearch) {
        
        let string = NSMutableAttributedString(string: entity.fullName, attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.mediumOfSize(14)])
        
        let lastNameString = NSMutableAttributedString(string: "\n\(entity.eid)", attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.lightOfSize(14)])
            string.appendAttributedString(lastNameString)

        let eidString = NSMutableAttributedString(string: "    \(entity.deptName)", attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.thinOfSize(14)])
            string.appendAttributedString(eidString)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        string.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, string.length))
        
        mainLabel.text = nil
        mainLabel.attributedText = string
    }
    
}