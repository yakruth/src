//
//  EmployeeSearchViewController.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/4/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

protocol EmployeeSearchViewControllerDelegate : NSObjectProtocol   {
    func setRequestForSelectedStringValue(sender: EmployeeSearchViewController, employeeSearch: EmployeeSearch)
}

class EmployeeSearchViewController: GAITrackedViewController    {

    /// Represents textfield container view
    @IBOutlet var containerView: UIView!
    /// Represents first name textfield
    @IBOutlet var firstNameTextField: UITextField!
    /// Represents last name textfield
    @IBOutlet var lastNameTextField: UITextField!
    /// Represents eid textfield
    @IBOutlet var eidTextField: UITextField!
    /// Represents textfield container view
    @IBOutlet var headerLabel: InsetLabel!
    /// Represents tableview
    @IBOutlet var tableView: UITableView!
    /// Represents the data source.
    var dataSource: ArrayDataSource<EmployeeSearch, EmployeeSearchTableViewCell>!
    /// The content tap gesture.
    private var tapGesture: UITapGestureRecognizer?
    /// Represents the delegate
    weak var delegate: EmployeeSearchViewControllerDelegate?

    /**
    view did load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "employeesearch".localized

        //startObserving()
        
        dataSource = ArrayDataSource(items: [[]], cellReuseIdentifier: "cell",
            configureClosure: { (cell, entity, _) -> Void in
                cell.configure(entity)
        })
        tableView.dataSource = dataSource.proxy
        
        headerLabel.text = "empresults".localized
        
        tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.containerView.addGestureRecognizer(tapGesture!)
        
        addBackItem()
    }
    
    /**
    view will appear
    
    parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Employee Search"  // Google Analytics screen name
    }
    
    /**
     View will disappear.
     
     - parameter animated: The animated
     */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObserving()
    }
    
    /**
    reset button action method
    */
    @IBAction func resetButtonTapped(sender: AnyObject) {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        eidTextField.text = ""
        
        self.dataSource.allItems = []
        self.tableView.reloadData()
        
        self.setTableViewHeaderTitle(0)
    }
    
    /** 
    search button action method
    */
    @IBAction func searchButtonTapped(sender: AnyObject)    {
        if self.validate() {
            self.searchData()
        }
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
    
    :param up: need to up or not
    :param moveValue: keyboard height
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
    *  sends text data to server asynchronously
    */
    func searchData() {

        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        ServerApi.sharedInstance.getUserDetailsListRequest(firstNameTextField.text!.trim(), lastName: lastNameTextField.text!.trim(), eid: eidTextField.text!.trim(), callback: { (list: [EmployeeSearch]) -> () in
            
            loginView.terminate()

            self.dataSource.allItems = [list]
            self.tableView.reloadData()
            self.displayAlert(list.count)
            self.setTableViewHeaderTitle(list.count)
            
            }) { (error: RestError, response: RestResponse?) -> () in
                loginView.terminate()
                ErrorView.show("Error_NoRequest".localized, inView: self.view)
        }

    }
    
    /**
    Update number of requests in the table header
    
    :parameter count: The array count
    */
    func setTableViewHeaderTitle(count: Int) {
        if count > 0    {
            headerLabel.text = "empresults".localized.stringByAppendingFormat(" (%d)", count)
        }
        else    {
            headerLabel.text = "empresults".localized
        }
    }

    /**
    Validate
    */
    func validate() -> Bool {
        if ((self.firstNameTextField.text?.trim().characters.count == 0) && (self.lastNameTextField.text?.trim().characters.count == 0) && (self.eidTextField.text?.trim().characters.count == 0))   {
            self.showAlert("emptyTextFields".localized)
            return false
        }
        return true
    }
    
    /** 
    Display Alert Box 
    */
    func displayAlert(count: Int) {
        if count == 50 {
            self.showAlert("resultsMoreThanCount".localized)
        }
        else if count == 0 {
            self.showAlert("noSearchResults".localized)
        }
    }
}

extension EmployeeSearchViewController : UITextFieldDelegate    {
    
    /**
     text field should return
     
    :parameter textfield: The Textfield
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        if self.validate() {
            self.searchData()
        }
        return true
    }
    
}

extension EmployeeSearchViewController : UITableViewDelegate    {
    /**
     Did select row at index path.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        delegate?.setRequestForSelectedStringValue(self, employeeSearch: (dataSource.itemAtIndexPath(indexPath)))
        navigationController?.popViewControllerAnimated(true)
    }
}

//Class InsetLabel
/**
Added by H146574

date    : 5-Feb-2016
version : 1.0
*/
class InsetLabel : UILabel {
    /**
    draw in rect
    */
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)))
    }
}