//
//  LoginKeyboardController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the login keyboard controller class.

@author mohamede1945
@version 1.0
*/
class LoginKeyboardController: NSObject {

    /// the login view controller
    weak var controller: LoginViewController?

    /**
    start observing.
    */
    func startObserving() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
    Stops observing.
    */
    func stopObserving() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
    Keyboard will be shown.

    - parameter notification: the notification object.
    */
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()

        controller?.bottomLayout.constant = keyboardSize.height
        controller?.loginLabelTop.constant = 15
        controller?.loginLabelBottom.constant = 12
        controller?.loginButtonTop.constant = 15
//        controller?.loginButtonBottom.constant = 0

        if UIApplication.sharedApplication().keyWindow?.bounds.width == 320 {
            controller?.infoView.pageControl.hidden = true
        }

        controller?.infoView.collectionView.reloadData()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.controller?.view.layoutIfNeeded()
            }, completion: nil)
        controller?.infoView.userInteractionEnabled = false
    }

    /**
    Keyboard will be hidden.

    - parameter notification: the notification object.
    */
    func keyboardWillHide(notification: NSNotification) {

        controller?.bottomLayout.constant = 0
        controller?.loginLabelTop.constant = 31
        controller?.loginLabelBottom.constant = 23
        controller?.loginButtonTop.constant = 23
        controller?.loginButtonBottom.constant = 43

        controller?.infoView.collectionView.reloadData()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.controller?.view.layoutIfNeeded()
            }, completion: nil)

        if UIApplication.sharedApplication().keyWindow?.bounds.width == 320 {
            controller?.infoView.pageControl.hidden = false
        }
        controller?.infoView.userInteractionEnabled = true
    }
}
