//
//  FeedbackViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/5/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Screen for general feedback
*
* - Author: Nikita Rodin
* :version: 1.1
*
* changes:
* 1.1:
* - new API methods integration
*/
class FeedbackViewController: SubmitViewController, UITextViewDelegate {

    // outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        separatorHeight.constant = 0.5
        self.title = "Application Feedback".localized
        textView.layer.borderColor = UIColor(r: 228, g:229, b: 231).CGColor
        textView.layer.borderWidth = 0.5
        
        // tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.view.addGestureRecognizer(tapGesture)
        
        // add menu
        self.addMenuButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Feedback"  // Google Analytics screen name
    }
    
    // MARK: - actions
    
    /**
    Validates form, messages user about any occured error
    
    - returns: true, if user can proceed
    */
    override func validate() -> Bool {
        if textView.text.trimmedString().isEmpty {
            self.showAlert("Feedback text cannot be empty".localized)
            return false
        }
        
        return true
    }
    
    /**
    view tap handler
    */
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    // MARK: - text view delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return newText.characters.count <= Configuration.sharedConfig.maxFeedbackLength
    }

    /**
    *  sends text data to server asynchronously
    */
    override func sendData(completion: () -> ()) {
        // mock sending
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        ServerApi.sharedInstance.feedback(textView.text.trim(), callback: { () -> () in
            loginView.terminate()
            completion()
        }) { (error: RestError, res: RestResponse?) -> () in
            error.showError()
            loginView.terminate()
        }
    }
}
