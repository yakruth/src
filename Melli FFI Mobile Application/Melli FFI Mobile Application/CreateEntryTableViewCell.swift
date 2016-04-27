//
//  CreateEntryTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the create entry table view cell class.

@author mohamede1945
@version 1.0
*/
class CreateEntryTableViewCell: UITableViewCell {

    /**
    *  The text field.
    */
    @IBOutlet weak var textField: UITextField!
    
    /// Represents the attach button
    @IBOutlet var attachbutton: UIButton!
    /// Represents the attachment label
    @IBOutlet var attachmentLabel: UILabel!
    /// Delegate
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

}
