//
//  BaseEditingViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the base editing view controller class.

@author mohamede1945
@version 1.0
*/
class BaseEditingViewController: KeyboardViewController /*VoiceRecogniserDelegate */ {

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!
    /// Represents the action button.
    @IBOutlet weak var actionButton: UIButton!

    /// Represents the picker view.
    @IBOutlet weak var pickerView: UIPickerView!
    /// Represents the picker cancel button.
    @IBOutlet weak var pickerCancel: UIButton!
    /// Represents the picker done button.
    @IBOutlet weak var pickerDone: UIButton!
    /// Represents the picker overlay.
    @IBOutlet weak var pickerOverlay: UIView!
    /// Represents the attachment button
    var attachmentButton: UIButton!
    
    //Represents the Send Request AlertView
    var sendRequestAlert: UIAlertView!
    
    var notesTextView: UITextView!
    
    /// Represents the Image Picker View Controller
    let imagePickerViewController = UIImagePickerController()

    /// Represents the request.
    var request: Request!

    /// Represents the textview color changed
    var btextViewEdit: Bool = false

    /// Represents the attachment activity entry text
    var actvityEntryText = "Create Activity Entry"
    /// Represents the attachment text
    var attachmentDetails = ""
    /// Represents the image name
    var attachmentImageName = ""
    /// Represents the base64string
    var base64String = ""
    /// Represents the summary text.
    var summaryText = ""
    /// Represents the notes text.
    var notesText = ""
    /// Represents the urgency.
    var urgency = Request.Urgency.Medium
    /// Represents the category.
    var template: TemplateLeaf?
    /// Represents the pickerType
    var pickerType: Bool = false
    /// Represents the imageURL
    var imageURL: NSURL!
    /// Represents the requested for string
    var requestedName: String!
    /// Represents the employee search
    var employeeSearch: EmployeeSearch?
    /// Represents the requested for eid
    var requestedForEid : String = ""
    /// Represents the summary, urgency, notes configurator.
    var summaryNotesConfigurer: GeneralCellConfigurer<NSString, SummaryUrgencyNotesTableViewCell>!

    /// Represents the data source.
    var dataSource: DisjointArrayDataSource!

    /**
    View did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController?.constant = -45
        actionButton.setBackgroundImage(UIColor(r: 232, g: 52, b: 23).image(), forState: .Normal)

        pickerCancel.setTitle("cancel".localized, forState: .Normal)
        pickerDone.setTitle("done".localized, forState: .Normal)
        let barItem = createNavigationItem("cancel".localized)
        let button = barItem.customView as! UIButton
        button.addTarget(self, action: "cancelButtonTapped", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = barItem

        tableView.registerNib(UINib(nibName: "SummaryUrgencyNotesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "summary")

        summaryText = request.summary
        notesText = request.notes
        urgency = request.urgency
        template = request.template
        requestedName = AuthenticationUtil.getUserInfo()?.getFullName() ?? ""
        requestedForEid = AuthenticationUtil.getUserInfo()?.username ?? ""
        
        summaryNotesConfigurer = GeneralCellConfigurer<NSString, SummaryUrgencyNotesTableViewCell> { [weak self] (cell, _, _) -> Void in
            cell.summaryLabel.text = "summary".localized
            cell.notesLabel.text = "notes".localized
            cell.urgencyLabel.text = "urgency".localized
            cell.summaryText.text = self?.summaryText
            cell.notesText.text = self?.notesText
            cell.urgencyDropDown.textField.text = self?.urgency.rawValue.localized ?? "selectUrgency".localized
            cell.urgencyDropDown.textField.delegate = self
            cell.summaryText.tag = 1
            cell.notesText.tag = 2

            cell.summaryText.delegate = self
            cell.notesText.delegate = self
            
            cell.attachmentTextView.layer.borderColor = UIColor.grayColor().CGColor
            cell.attachmentTextView.layer.borderWidth = 0.5
            cell.attachmentTextView.tag = 3
            cell.attachmentTextView.delegate = self
            
            cell.attachmentTextView.text = self?.actvityEntryText
            if self?.actvityEntryText == "Create Activity Entry"    {
                cell.attachmentTextView.textColor = UIColor.lightGrayColor()
            }
            else {
                cell.attachmentTextView.textColor = UIColor.blackColor()
            }
            
            cell.attachmentLabel.text = self?.attachmentDetails
            cell.delegate = self
            
            cell.requestedTextField.text = self!.requestedName
            cell.requestedTextField.delegate = self
            
            self!.attachmentButton = cell.attachbutton
            
            self!.notesTextView = cell.notesText
        }

    }
    
    /**
    View did appear
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
    View will appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    /**
    picker cancel button tapped.

    - parameter sender: The sender
    */
    @IBAction func pickerCancelTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
            options: UIViewAnimationOptions(), animations: { () -> Void in
                self.pickerOverlay.alpha = 0
            }, completion: { (_) -> Void in
                self.pickerOverlay.hidden = true
        })
    }

    /**
    Picker done button tapped.

    - parameter sender: The sender
    */
    @IBAction func pickerDoneTapped(sender: AnyObject) {
        urgency = urgencyAtRow(pickerView.selectedRowInComponent(0))
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SummaryUrgencyNotesTableViewCell {
            cell.urgencyDropDown.textField.text = urgency.rawValue.localized ?? "selectUrgency".localized
        } else if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? SummaryUrgencyNotesTableViewCell {
            cell.urgencyDropDown.textField.text = urgency.rawValue.localized ?? "selectUrgency".localized
        }

        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
            options: UIViewAnimationOptions(), animations: { () -> Void in
                self.pickerOverlay.alpha = 0
            }, completion: { (_) -> Void in
                self.pickerOverlay.hidden = true
        })
    }

    /**
    Validates the view

    - returns: true, if validation succeeded.
    */
    func validate() -> Bool {
        view.endEditing(true)
        if notesText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0   {
            UIAlertView(title: "validationError".localized, message: "notesRequired".localized,
                delegate: nil, cancelButtonTitle: "ok".localized).show()
            return false
        }
//        if template == nil {
//            UIAlertView(title: "validationError".localized, message: "templateRequired".localized,
//                delegate: nil, cancelButtonTitle: "ok".localized).show()
//            return false
//        }

        // disable validation for now as it will be truncated on the server.
        //        if summaryText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 100 {
        //            UIAlertView(title: "validationError".localized, message: "summaryMoreThan100".localized,
        //                delegate: nil, cancelButtonTitle: "ok".localized).show()
        //            return false
        //        }
        //        if notesText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 160 {
        //            UIAlertView(title: "validationError".localized, message: "notesMoreThan160".localized,
        //                delegate: nil, cancelButtonTitle: "ok".localized).show()
        //            return false
        //        }

        return true
    }

    /**
    Navigate to confirmation screen.

    - parameter request: The request
    */
    func navigateToConfirmation(request: Request) {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("confirmation") as? ConfirmationViewController {
            vc.request = request
            navigationController?.setViewControllers([vc], animated: true)
        }
    }

    private func urgencyAtRow(row: Int) -> Request.Urgency {
        return Request.Urgency.urgencies()[row]
    }

    private func rowForUrgency(target: Request.Urgency) -> Int {
        for (i, urgency) in Request.Urgency.urgencies().enumerate() {
            if target == urgency {
                return i
            }
        }
        return -1
    }
    
}

extension BaseEditingViewController : UIAlertViewDelegate {
    /**
    Alert view button tapped.

    - parameter alertView:   The alert view
    - parameter buttonIndex: The button index
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if navigationController?.viewControllers.count > 1 {
                // go back
                navigationController?.popViewControllerAnimated(true)
                
            } else if let slideVC = slideMenuController,
                let menuVC = slideVC.sideController as? MenuViewController,
                let controller = menuVC.createContentControllerForItem(.Home) {
                    // go to home
                    slideVC.setContentViewController(controller)
                    menuVC.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0),
                        animated: false, scrollPosition: .Top)
                    
            }
        }
    }
}

extension BaseEditingViewController: UITextFieldDelegate {
    /**
    Should text field begin editing.

    - parameter textField: The text field

    - returns: true, if should begin editing.
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        view.endEditing(true)
        if (textField.tag != 11)  {
            // open urgency selection
            pickerOverlay.superview?.bringSubviewToFront(pickerOverlay)
            pickerOverlay.hidden = false
            pickerOverlay.alpha = 0
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.pickerOverlay.alpha = 1
                }, completion: nil)
            pickerView.selectRow(rowForUrgency(urgency), inComponent: 0, animated: false)
        }
        return false
    }
}

extension BaseEditingViewController : UITextViewDelegate {

    /** 
    Text view did begin editing
    */
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.tag == 3 && textView.text == "Create Activity Entry"  {
            if btextViewEdit == false   {
                textView.text = ""
                textView.textColor = UIColor.blackColor()
                btextViewEdit = true
            }
        }
    }
    
    /**
    Text view did end editing.

    - parameter textView: The text view
    */
    func textViewDidEndEditing(textView: UITextView) {
        if textView.tag == 1 {
            summaryText = textView.text
        } else if textView.tag == 2 {
            notesText = textView.text
        }
        else if textView.tag == 3   {
            if btextViewEdit == true    {
                actvityEntryText = textView.text
            }
            else    {
                actvityEntryText = ""
            }
            if textView.text == ""  {
                textView.text = "Create Activity Entry"
                textView.textColor = UIColor.lightGrayColor()
                btextViewEdit = false
            }
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.tag != 1 {
            return true
        }
        let oldText = textView.text
        let stringRange = Range<String.Index>(
            start: oldText.startIndex.advancedBy(range.location),
            end: oldText.startIndex.advancedBy(range.location + range.length))
        let text = textView.text.stringByReplacingCharactersInRange(stringRange, withString: text)

        return text.characters.count <= 100
    }
}

extension BaseEditingViewController : UIPickerViewDataSource, UIPickerViewDelegate {

    /**
    Number of components for picker view

    - parameter pickerView: The picker view

    - returns: number of components.
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    /**
    Number of rows in component.

    - parameter pickerView: The picker view
    - parameter component:  The component

    - returns: number of rows in component.
    */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Request.Urgency.urgencies().count
    }

    /**
    Title for row at component.

    - parameter pickerView: The picker view
    - parameter row:        The row
    - parameter component:  The component

    - returns: the title for the row.
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        let urgency = urgencyAtRow(row)
        return urgency.rawValue.localized
    }



}

extension BaseEditingViewController : AttachmentViewDelegate    {

    /**
    */
    func showAttachmentActionSheet(tagNumber: Int, sender: AnyObject) -> NSString    {
        
        if tagNumber == 0   {
            let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
            
            let attachPhotoAction = UIAlertAction(title: "Attach a File", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.pickerType = false
                self.imagePickerViewController.delegate = self
                self.imagePickerViewController.allowsEditing = false
                self.imagePickerViewController.sourceType = .PhotoLibrary
                self.presentViewController(self.imagePickerViewController, animated: true, completion: nil)
                
            })
            let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.pickerType = true
                self.imagePickerViewController.delegate = self
                self.imagePickerViewController.allowsEditing = false
                self.imagePickerViewController.sourceType = .Camera
                self.imagePickerViewController.cameraCaptureMode = .Photo
                self.imagePickerViewController.modalPresentationStyle = .FullScreen
                self.presentViewController(self.imagePickerViewController, animated: true, completion: nil)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.pickerType = false
                tagNumber == 0 ? sender.setBackgroundImage(UIImage(named: "Attach"), forState : .Normal) : sender.setBackgroundImage(UIImage(named: "CancelAttachment"), forState : .Normal)
            })
            
            optionMenu.addAction(attachPhotoAction)
            optionMenu.addAction(cameraAction)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        else if tagNumber == 1  {
            attachmentDetails = ""
            base64String = ""
            self.tableView.reloadData()
        }
        return ""
    }

    /**
    */
    func showEmployeeSearchViewController(sender: AnyObject)    {
        if let employeeSearchVC = storyboard?.instantiateViewControllerWithIdentifier("employeesearch") as? EmployeeSearchViewController {
            employeeSearchVC.delegate = self
            navigationController?.pushViewController(employeeSearchVC, animated: false)
        }
    }

}

extension BaseEditingViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate    {
    
    /**
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])   {
        if pickerType == true   {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let imageData = UIImageJPEGRepresentation(pickedImage, 0.6)
                let compressedJPGImage = UIImage(data: imageData!)
                UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
                
                var imageSize = Float(imageData!.length)
                
                //Transform into Megabytes
                imageSize = imageSize/(1024*1024)
                

                attachmentDetails = String(format: "%@ : %.2f MB", "asset.jpg", imageSize)
                
                base64String = imageData!.base64String()
            }
        }
        else    {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                let newimage = SquareImageTo(pickedImage, size: CGSizeMake(600, 960))
                let imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL
                attachmentImageName = imageURL!.lastPathComponent!
                
                var imageData : NSData!
                print ("imageURL!.pathExtension!: \(imageURL!.pathExtension!)")
                if (imageURL!.pathExtension!.caseInsensitiveCompare("jpg") == .OrderedSame) {
                    imageData =  UIImageJPEGRepresentation(newimage, 1.0)! as NSData
                }
                else if (imageURL!.pathExtension!.caseInsensitiveCompare("png") == .OrderedSame)  {
                    imageData =  UIImagePNGRepresentation(newimage)! as NSData
                }
                
                //Get bytes size of image
                var imageSize = Float(imageData.length)
                
                //Transform into Megabytes
                imageSize = imageSize/(1024*1024)
                
                attachmentDetails = String(format: "%@ : %.2f MB", attachmentImageName, imageSize)
                
                base64String = imageData.base64String()
            }
        }
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.attachmentButton.setBackgroundImage(UIImage(named: "Attach"), forState : .Normal)
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension BaseEditingViewController : EmployeeSearchViewControllerDelegate  {
    /**
    set the value of the selected employee search string
    
    : param sender: The employee search view controller object
    : param employeeSearch: The employee search
    */
    func setRequestForSelectedStringValue(sender: EmployeeSearchViewController, employeeSearch: EmployeeSearch)    {
        self.employeeSearch = employeeSearch
        self.requestedForEid = employeeSearch.eid
        self.requestedName = employeeSearch.fullName
        self.tableView.reloadData()
    }
}