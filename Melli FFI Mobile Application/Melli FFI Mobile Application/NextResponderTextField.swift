//
//  NextResponderTextField.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the next responder text field class.

@author mohamede1945
@version 1.0
*/
class NextResponderTextField: UITextField {

    /// Represents the next field.
    @IBOutlet weak var nextField: UIView?

    /**
    Return tapped
    */
    func returnTapped() {
        if let field = nextField as? UIButton {
            if field.enabled {
                field.sendActionsForControlEvents(.TouchUpInside)
            } else {
                resignFirstResponder()
            }
        } else {
            if let field = nextField {
                field.becomeFirstResponder()
            } else {
                resignFirstResponder()
            }
        }
    }
}

extension NextResponderTextField : UITextFieldDelegate {

    /**
    text field should return.

    - parameter textField: The text field

    - returns: always true.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let field = textField as? NextResponderTextField {
            field.returnTapped()
        }
        return true
    }
}