//
//  ITCustomerSentimentViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Honeywell International Inc on 10/30/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

class ITCustomerSentimentViewController: SubmitViewController, UITextViewDelegate   {
    
    // outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var contactSwitch: UISwitch!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!

    var buttonTagNumber: Int? = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Do any additional setup after loading the view.
        self.title = "itCustomerSentiment".localized
        
        // tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.view.addGestureRecognizer(tapGesture)
        
        // textview color
        textView.layer.borderColor = UIColor(r: 228, g:229, b: 231).CGColor
        textView.layer.borderWidth = 0.5
        
        // add menu
        self.addMenuButton()
        
        startObserving()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "IT Customer Sentiment"  // Google Analytics screen name
    }
    
    /**
    View will disappear.
    
    - parameter animated: The animated
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObserving()
    }

    /*!
    Start observing keyboard will hide and did show events.
    */
    func startObserving() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:",
            name: UIKeyboardDidShowNotification, object: nil)
    }
    
    /*!
    Stops observing
    */
    func stopObserving() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }

    /*!
    Keyboard will hide.
    :param: notification the notification object.
    */
    func keyboardWillHide(notification: NSNotification) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardSize: CGSize = keyboardFrame.size

        animateViewMoving(false, moveValue: (keyboardSize.height - 45))
    }

    /*!
    Keyboard did show.
    :param: notification the notification object.
    */
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardSize: CGSize = keyboardFrame.size

        animateViewMoving(true, moveValue: (keyboardSize.height - 45))
    }
    
    /*!
    animate view.
    :param: 
    :param:
    */
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    
    /**
    view tap handler
    */
    func viewTapped() {
        self.view.endEditing(true)
    }

    /**
    Validates form, messages user about any occured error
    
    - returns: true, if user can proceed
    */
    override func validate() -> Bool {
        
        if buttonTagNumber == 0 {
            self.showAlert("Please select a star rating")
            return false
        }
        
        /*if textView.text.trimmedString().isEmpty {
            self.showAlert("TextView cannot be empty".localized)
            return false
        }*/
        
        return true
    }

    // MARK: - text view delegate

    /*func textView(textView: UITextView,  shouldChangeTextInRange range:NSRange, replacementText text:String ) -> Bool {
        return count(textView.text) + (count(text) - range.length) <= 300;
    }*/
    
    
    /**
    *  sends text data to server asynchronously
    */
    override func sendData(completion: () -> ()) {
        // mock sending
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        
        let rate = String(buttonTagNumber!)
        let contactmeVal = String(stringInterpolationSegment: contactSwitch.on)

        ServerApi.sharedInstance.customerSentimentFeedback(rate, comment: textView.text.trim(), contactme: contactmeVal, callback: { () -> () in
            loginView.terminate()
            completion()
            }) { (error: RestError, res: RestResponse?) -> () in
                error.showError()
                loginView.terminate()
        }
    }

    
    @IBAction func tappedOnStarButton(sender: AnyObject) {
        
        buttonTagNumber = sender.tag
        
        switch buttonTagNumber!   {
        case 1:
            starLabel.text = "Disappointed"
            break;
            
        case 2:
            starLabel.text = "Unhappy"
            break;
            
        case 3:
            starLabel.text = "Indifferent"
            break;
            
        case 4:
            starLabel.text = "Happy"
            break;
            
        case 5:
            starLabel.text = "Delighted"
            break;
            
        case 0:
            starLabel.text = ""
            break;
            
        default:
            assertionFailure("Invalid Button Tag")
            break;
        }
        
        rateStar(sender)
    }
    
    /**
    Reset the StarButton Image
    
    - returns: void
    */
    func rateStar(sender: AnyObject)   {
        var image: UIImage? = nil
        var imageName: String? = nil
        
        for var i = 1; i <= 5; i++ {
            if i <= sender.tag  {
                imageName = "starOn"
            }
            else {
                imageName = "starOff"
            }
            image = UIImage (named: imageName!) as UIImage?
            if let button = self.view.viewWithTag(i) as? UIButton {
                button.setImage(image, forState: .Normal)
            }
        }
    }

}
