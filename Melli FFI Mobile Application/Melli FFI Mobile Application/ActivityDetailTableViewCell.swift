//
//  ActivityDetailTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 1/28/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the delegate

@author manjunath
@version 1.0
*/
protocol ActivityDetailTableViewCellDelegate  : NSObjectProtocol   {
    
    /**
    callDownloadApi
    */
    func callDownloadApi(sender: AnyObject, entity: RequestAttachActivity, activitydetail: ActivityDetailTableViewCell) -> Bool
    
}


/*!
Represents the label table view cell class.

@author mohamede1945
@version 1.0
*/
class ActivityDetailTableViewCell: UITableViewCell {
    
    /// Represents the label.
    @IBOutlet weak var label: UILabel!
    /// Represents the line view.
    @IBOutlet weak var lineView: UIView!
    /// Represents the attachment button.
    @IBOutlet weak var attachmentButton: UIButton!
    
    /// Represents the request attach ativity
    var entity: RequestAttachActivity!
    /// Represents the delegate
    weak var delegate: ActivityDetailTableViewCellDelegate?
    /// Represents the height of the button
    var height: CGFloat = 42.0

    /// Represents the date formatter.
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return formatter
    }()

    /**
     Creates a new view with the passed coder.
     
     - parameter aDecoder: The a decoder
     
     - returns: the created new view.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setUp()
    }
    
    /**
     Creates a new view with the passed style and identifier.
     
     - parameter style:           The style
     - parameter reuseIdentifier: The reuse identifier
     
     - returns: the created new view.
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    /**
     Sets up the view.
     */
    func setUp() {
        attachmentButton.alignImageRight()
    }

    /**
    Download Button Action
    
    :param sender: The sender of anyobject
    */
    @IBAction func downloadAttachmentButtonTapped(sender: AnyObject) {
        delegate!.callDownloadApi(sender, entity: entity, activitydetail:self)
    }
    
}


extension ActivityDetailTableViewCell {
    
    /**
     Configure the cell.
     
     - parameter entity: The entity
     */
    func configure(entity: RequestAttachActivity) {
        
        self.entity = entity
        
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
        
        let date = ActivityDetailTableViewCell.formatter.stringFromDate(entity.date)
        
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
        
        if (entity.attachedNames.count > 0) {
            attachmentButton.setTitle(entity.attachedNames[0], forState: .Normal)
            attachmentButton.setImage(UIImage(named: "Attach"), forState: .Normal)
        }
        else    {
            attachmentButton.setTitle("", forState: .Normal)
            attachmentButton.setImage(nil, forState: .Normal)
        }
    }
    
}

extension UIButton {
    
    /// Makes the ``imageView`` appear just to the right of the ``titleLabel``.
    func alignImageRight()  {
        if let titleLabel = self.titleLabel, imageView = self.imageView {
            // Force the label and image to resize.
            titleLabel.sizeToFit()
            imageView.sizeToFit()
            imageView.contentMode = .ScaleAspectFit
            
            // Set the insets so that the title appears to the left and the image appears to the right.
            // Make the image appear slightly off the top/bottom edges of the button.
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1 * imageView.frame.size.width,
                bottom: 0, right: imageView.frame.size.width)
            self.imageEdgeInsets = UIEdgeInsets(top: 4, left: titleLabel.frame.size.width,
                bottom: 4, right: -1 * titleLabel.frame.size.width)
        }
    }
    
}