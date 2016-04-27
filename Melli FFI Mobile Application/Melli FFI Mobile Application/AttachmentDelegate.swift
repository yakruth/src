//
//  AttachmentDelegate.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 12/15/15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

@objc public protocol AttachmentViewDelegate : NSObjectProtocol   {
    
    //func showAttachmentActionSheet(string: NSString) -> NSString

    /**
    */
    func showAttachmentActionSheet(tagNumber: Int, sender: AnyObject) -> NSString

    /**
    */
    optional func showEmployeeSearchViewController(sender: AnyObject)

}

