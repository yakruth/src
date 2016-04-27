//
//  KeyboardController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
*  The keyboard controller class.
*  @author mohamede1945
*  @version 1.0
*/
class KeyboardController : NSObject {

    /// the adjustable constraint
    var adjustableConstraint: NSLayoutConstraint?

    /// the view
    let view: UIView

    /// the initial constant
    private var initialConstant = 0 as CGFloat

    /// a muliplier used for the constraint calculation
    var multiplier = 1 as CGFloat
    /// a constant used for the constraint calculation
    var constant = 0 as CGFloat
    /// should use animation for keyboard did show.
    var usesAnimationInShowing = false

    /// whether the keyboard is open or not
    var isShowing = false

    /*!
    Intialize new instance of the controller.
    :param: adjustableConstraint the constraint to modify.
    :param: the parent view of the constraint.
    */
    init(adjustableConstraint: NSLayoutConstraint?, view: UIView) {
        self.adjustableConstraint = adjustableConstraint
        self.view = view
    }

    /*!
    Deinitializer.
    */
    deinit {
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
        if !isShowing {
            return
        }
        isShowing = false

        adjustableConstraint?.constant = initialConstant
        view.layoutIfNeeded()
    }

    /*!
    Keyboard did show.
    :param: notification the notification object.
    */
    func keyboardDidShow(notification: NSNotification) {
        if isShowing {
            return
        }
        isShowing = true

        // get first responder
        let textView = UIApplication.sharedApplication().keyWindow?.findFirstResponder() as? UITextView


        initialConstant = adjustableConstraint?.constant ?? 0

        let userInfo = notification.userInfo!
        let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardFrameInViewCoordinates = view.convertRect(frame, fromView: nil)
        let keyboardHeight = CGRectGetHeight(view.bounds) - keyboardFrameInViewCoordinates.origin.y
        adjustableConstraint?.constant = initialConstant + (keyboardHeight * multiplier) + constant

        if usesAnimationInShowing && textView == nil {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: [], animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            view.layoutIfNeeded()
            if let textView = textView {
                if let scrollView = adjustableConstraint?.firstItem as? UIScrollView ??
                    adjustableConstraint?.secondItem as? UIScrollView {
                        if textView.isDescendantOfView(scrollView) {
                            // scroll to visible rect
                            let textFrame = scrollView.convertRect(textView.frame, fromView: textView.superview)
                            scrollView.scrollRectToVisible(textFrame, animated: true)
                        }
                }
            }
        }
    }
}

private extension UIView {
    /**
    Finds the first responder

    - returns: the first responder, or nil if nothing found.
    */
    private func findFirstResponder() -> UIView? {
        if isFirstResponder() { return self }
        else {
            for view in subviews {
                if let responder = view.findFirstResponder() {
                    return responder
                }
            }
            return nil
        }
    }
}

/*!
*   The keyboard view controller class, it's used for view controllers having text fields.
*  @author mohamede1945, Alexander Volkov
* @version 1.1
*
* changes:
* 1.1:
* - Google Analytics support
*/
class KeyboardViewController: GAITrackedViewController {

    /// the keyboard controller
    var keyboardController: KeyboardController?

    /// the adjustable constraint
    @IBOutlet weak var adjustableConstraint: NSLayoutConstraint? {
        didSet {
            if let controller = keyboardController {
                controller.adjustableConstraint = adjustableConstraint
            }
        }
    }

    /*!
    The view did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController = KeyboardController(adjustableConstraint: adjustableConstraint, view: view)
        keyboardController?.startObserving()
    }
}
