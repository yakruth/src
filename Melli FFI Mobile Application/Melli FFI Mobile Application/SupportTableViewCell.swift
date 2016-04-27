//
//  SuSupportTableViewCell.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the support table view cell class.

@author mohamede1945

@version 1.0
*/
class SupportTableViewCell: UITableViewCell {

    /// Represents the name label property.
    @IBOutlet weak var nameLabel: UILabel!
    /// Represents the description label property.
    @IBOutlet weak var descriptionLabel: UILabel!
    /// Represents the email label property.
    @IBOutlet weak var emailLabel: UILabel!

}


extension SupportTableViewCell {

    /**
    Configure for email.

    - parameter email: The email parameter.
    */
    func configureFor(email: EmailSupport) {
        nameLabel.text = email.name
        descriptionLabel.text = email.text
        emailLabel.text = email.email
    }

    /**
    Configure for phone.

    - parameter phone: The phone parameter.
    */
    func configureFor(phone: PhoneSupport) {
        nameLabel.text = phone.name
        descriptionLabel.text = phone.text
        emailLabel.text = phone.phone
    }
}