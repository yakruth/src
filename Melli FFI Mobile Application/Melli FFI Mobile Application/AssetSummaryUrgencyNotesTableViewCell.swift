//
//  AssetSummaryUrgencyNotesTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/22/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the asset summary urgency notes table view cell class.

*/
class AssetSummaryUrgencyNotesTableViewCell: UITableViewCell {
    
    /// Represents the summary label.
    @IBOutlet weak var summaryLabel: UILabel!
    /// Represents the notes label.
    @IBOutlet weak var notesLabel: UILabel!
    /// Represents the urgency label.
    @IBOutlet weak var urgencyLabel: UILabel!
    /// Represents the summary text.
    @IBOutlet weak var summaryText: UITextView!
    /// Represents the notes text.
    @IBOutlet weak var notesText: UITextView!
    /// Represents the urgency drop down.
    @IBOutlet weak var urgencyDropDown: DropDownView!
    /// Represents the asset textfield
    @IBOutlet weak var assetNameTextField: UITextField!
    /// Represents the attachment Text View
    @IBOutlet var attachmentTextView: UITextView!
    /// Represents the attachment button
    @IBOutlet var attachbutton: UIButton!
    /// Represents the attachment label
    @IBOutlet var attachmentLabel: UILabel!
    /// Represents the delegate
    weak var delegate: AttachmentViewDelegate?
    
    /**
     Attach Button Action Method
     */
    @IBAction func attachmentButtonAction(sender: AnyObject!)    {
        //delegate?.showAttachmentActionSheet(attachbutton.titleLabel!.text!)
        let parStr = attachbutton.tag == 0 ? "Attach".localized : "Cancel".localized
        delegate?.showAttachmentActionSheet(attachbutton.tag, sender: attachbutton)
        
        attachbutton.tag = attachbutton.tag == 0 ? 1 : 0
        //        attachbutton.tag == 0 ? attachbutton.setTitle("Attach", forState : .Normal) : attachbutton.setTitle("Cancel", forState : .Normal)
        attachbutton.tag == 0 ? attachbutton.setBackgroundImage(UIImage(named: "Attach"), forState : .Normal) : attachbutton.setBackgroundImage(UIImage(named: "CancelAttachment"), forState : .Normal)
        
    }
    
    /**
     Employee Search Action Method
     */
    @IBAction func employeeSearchButtonTapped(sender: AnyObject!)    {
        delegate?.showEmployeeSearchViewController!(sender)
    }
    
}
