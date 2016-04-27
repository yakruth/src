//
//  LabelTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the label table view cell class.

@author mohamede1945
@version 1.0
*/
class LabelTableViewCell: UITableViewCell {

    /// Represents the label.
    @IBOutlet weak var label: UILabel!

    /// Represents the date formatter.
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return formatter
        }()

}


extension LabelTableViewCell {

    /**
    Configure the cell.

    - parameter entity: The entity
    */
    func configure(entity: RequestActivity) {

        let string = NSMutableAttributedString(string: entity.name, attributes: [
            NSForegroundColorAttributeName: UIColor(r: 75, g: 144, b: 223),
            NSFontAttributeName: UIFont.mediumOfSize(14)])

        if let title = entity.title where !title.trimmedString().isEmpty {
            let titleString = NSAttributedString(string: " (\(title))", attributes: [
                NSForegroundColorAttributeName: UIColor(r: 149, g: 157, b: 166),
                NSFontAttributeName: UIFont.systemFontOfSize(12)])
            string.appendAttributedString(titleString)
        }
        let textString = NSAttributedString(string: "\n\(entity.text)", attributes: [
            NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58),
            NSFontAttributeName: UIFont.lightOfSize(14)])
        string.appendAttributedString(textString)

        let date = LabelTableViewCell.formatter.stringFromDate(entity.date)

        let index = date.endIndex.predecessor().predecessor()
        let dateFormatted = date.substringToIndex(index) + date.substringFromIndex(index).lowercaseString

        let dateString = NSAttributedString(string: "\n\(dateFormatted)", attributes: [
            NSForegroundColorAttributeName: UIColor(r: 131, g: 137, b: 148),
            NSFontAttributeName: UIFont.lightOfSize(12)])
        string.appendAttributedString(dateString)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        string.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, string.length))

        label.text = nil
        label.attributedText = string
    }
}

extension LabelTableViewCell    {
    
    /**
     Configure the cell.
     
     - parameter entity: The entity
     */
    func notesConfigure(entity: DetailNotes)    {
        let string = NSMutableAttributedString(string: "\("requestedfor".localized): \(entity.requestedFor)", attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58),
            NSFontAttributeName: UIFont.lightOfSize(15)])

        let byString = NSAttributedString(string: "\n\("requestedby".localized): \(entity.requestedBy)", attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58),
            NSFontAttributeName: UIFont.lightOfSize(15)])
        string.appendAttributedString(byString)
        
        let notes = NSAttributedString(string: "\n\(entity.notes)", attributes: [
            NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58),
            NSFontAttributeName: UIFont.lightOfSize(15)])
        string.appendAttributedString(notes)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        string.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, string.length))
        
        label.text = nil
        label.attributedText = string
    }
    
}