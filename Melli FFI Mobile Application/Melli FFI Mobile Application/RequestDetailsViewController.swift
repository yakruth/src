//
//  RequestDetailsViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the request details view controller class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - intergration with server API
*/
class RequestDetailsViewController: KeyboardViewController  {

    /// Represents the table view top constraint
    @IBOutlet weak var tableviewConstraint: NSLayoutConstraint?
    /// Represents the table view constraint constant
    private var tableViewConstant = 0 as CGFloat
    /// Represents the number label.
    @IBOutlet weak var contentView: UIView!
    /// Represents the number label.
    @IBOutlet weak var numberLabel: UILabel!
    /// Represents the edit button.
    @IBOutlet weak var editButton: UIButton!
    /// Represents the summary label.
    @IBOutlet weak var summaryLabel: UILabel!
    /// Represents the date label.
    @IBOutlet weak var dateLabel: UILabel!
    /// Represents the action button.
    @IBOutlet weak var actionButton: UIButton!
    /// Represents the status label.
    @IBOutlet weak var statusLabel: UILabel!
    /// Represents the color view.
    @IBOutlet weak var colorView: UIView!
    /// Represents the submit button
    @IBOutlet weak var submitButton: UIButton!
    /// Represents the activity text field
    var activityTextField: UITextField!
    /// Represents the attach button
    var attachmentButton: UIButton!
    /// Represents the view frame
    var viewFrame: CGRect!

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!
    
    /// Represents the Image Picker View Controller 
    let imagePickerViewController = UIImagePickerController()

    /// Represents the request.
    var request: Request!
    
    /// Represents the attachment text
    var attachmentDetails = ""
    
    /// Represents the textview color changed
    var btextViewEdit: Bool = false

    /// Represents the data source.
    var dataSource: DisjointArrayDataSource!
    
    /// Represents the base 64 string
    var base64String: String = ""
    
    /// Represents attachment image name
    var attachmentImageName: String = ""
    
    /// Represents textview text
    var activitytext: String = ""
    
    /// Represents pickerType 
    var pickerType: Bool = false
    
    /// Represents the sections.
    private var sections: [Section] = []
    
    /// API
    let api = ServerApi.sharedInstance
    
    /**
    View did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackItem()
        title = "requestDetails".localized

        self.viewFrame = self.view.frame

        editButton.setTitle("edit".localized, forState: .Normal)
        /// Added by H146574
        submitButton.setTitle("submit".localized, forState: .Normal)
        submitButton.setBackgroundImage(UIColor(r: 232, g: 52, b: 23).image(), forState: .Normal)

        tableviewConstraint?.constant = tableViewConstant

        let requestAgain = createNavigationItem("requestAgain".localized)
        //CParish - removed request again for release 1
        /*
        (requestAgain.customView as! UIButton).addTarget(self, action: "requestAgainTapped", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = requestAgain
        */
        updateDateLabel(request.date)
        numberLabel.text = request.incidentId
        summaryLabel.text = request.summary
        statusLabel.text = request.status.rawValue.localized
        statusLabel.textColor = request.status.getColor()
        
        //cparish - updatd to set background color
        //colorView.backgroundColor = request.status.getColor()
        colorView.backgroundColor = request.status.getBackgroundColor()
        
        updateStatusAction()
        updateDateLabel(request.date)
        
        tableView.registerNib(UINib(nibName: "CollapsibleTableViewCell", bundle: nil), forCellReuseIdentifier: "header")
        tableView.registerNib(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "label")
        tableView.registerNib(UINib(nibName: "ActivityDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "activityAttachlabel")
        
        let notesSection = Section()
        notesSection.name = "details".localized
        let note = DetailNotes()
        note.notes = request.notes
        note.requestedFor = request.requestedFor
        note.requestedBy = request.requestedBy
        notesSection.items = [note]
        
        let activitySection = Section()
        activitySection.name = "activity".localized
        activitySection.items = [CreateEntry()]
        activitySection.items += request.activities as [NSObject]

        sections = [notesSection, activitySection]
        
        let activityConfigurer = GeneralCellConfigurer<RequestActivity, LabelTableViewCell> { (cell, entity, _) -> Void in
            cell.configure(entity)
            //cell.createButtonDynamically(entity)
            //cell.delegate = self
        }
        let activityAttachConfigurer = GeneralCellConfigurer<RequestAttachActivity, ActivityDetailTableViewCell> { (cell, entity, _) -> Void in
            cell.configure(entity)
            //cell.createButtonDynamically(entity)
            cell.delegate = self
        }
        let sectionConfigurer = GeneralCellConfigurer<Section, CollapsibleTableViewCell> { (cell, entity, _) -> Void in
            cell.nameLabel.text = entity.name
            cell.arrowImage.image = UIImage(named: entity.collapsed ? "arrow-down" : "arrow-up")
        }
        let noteConfigurer = GeneralCellConfigurer<DetailNotes, LabelTableViewCell> { (cell, entity, _) -> Void in
           cell.notesConfigure(entity)
        }
        let entryConfigurer = GeneralCellConfigurer<CreateEntry, CreateEntryTableViewCell> { (cell, entity, _) -> Void in
            self.activityTextField = cell.textField
            cell.textField.text = entity.value
            cell.textField.placeholder = "createEntry".localized
            cell.textField.delegate = self
            
            cell.attachmentLabel.text = self.attachmentDetails
            cell.delegate = self
            self.attachmentButton = cell.attachbutton
            if self.btextViewEdit == true   {
                cell.attachbutton.tag = 0
                cell.attachbutton.setBackgroundImage(UIImage(named: "Attach"), forState : .Normal)
                self.btextViewEdit = !self.btextViewEdit
            }
        }
        
        dataSource = DisjointArrayDataSource(items: [getItems()], cellConfigurers: [
            (type: RequestActivity.self, reuseIdentifier: "label", configurer: activityConfigurer),
            (type: RequestAttachActivity.self, reuseIdentifier: "activityAttachlabel", configurer: activityAttachConfigurer),
            (type: Section.self, reuseIdentifier: "header", configurer: sectionConfigurer),
            (type: DetailNotes.self, reuseIdentifier: "label", configurer: noteConfigurer),
            (type: CreateEntry.self, reuseIdentifier: "entry", configurer: entryConfigurer)])
        
        tableView.dataSource = dataSource
        
        loadData()
        
        startObserving()
    }
    
    /**
    Setup Google Analytics screen name when appear.
    
    - parameter animated: animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Request Details" // Google Analytics screen name
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
    Update request date label
    
    - parameter date: the date
    */
    func updateDateLabel(date: NSDate) {
        struct Static {
            static var dateFormatter: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "MMM dd, yyyy hh:mm a"
                return f
                }()
        }
        let date = Static.dateFormatter.stringFromDate(date)
        let index = date.endIndex.predecessor().predecessor()
        let dateFormatted = date.substringToIndex(index) + date.substringFromIndex(index).lowercaseString
        dateLabel.text = dateFormatted
    }

    func updateStatusAction() {
        if let action = request.status.nextStatus()?.action {
            actionButton.setTitle(action, forState: .Normal)
            actionButton.hidden = false
        } else {
            actionButton.hidden = true
        }
    }
    
    /**
    Load data from API
    */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.backgroundColor = UIColor.clearColor()
        loginView.show()
        let activitySection = Section()

        api.getWorkInfoParsed(request.incidentId, callback: { (activities: [AnyObject]) -> () in
            
            loginView.terminate()
            
            // Update activities in Request
            self.request.activities = activities as! [RequestActivity]
            
            // Update model for UI
            activitySection.name = "activity".localized
            activitySection.items = [CreateEntry()]
            activitySection.items += activities as! [NSObject]
            
            self.activitytext = ""
            self.base64String = ""
            self.attachmentDetails = ""
            self.attachmentImageName = ""
            self.activityTextField.text = self.activitytext
            
            let notesSection = self.sections[0]
            
            self.sections = [notesSection, activitySection]
            self.dataSource.items = [self.getItems()]
            
            self.tableView.reloadData()
            
            }, AttachmentCallback:  {(activities: [RequestAttachActivity]) -> () in
                
                loginView.terminate()
                activitySection.items += self.request.activities as [NSObject]
                self.request.attachActivities = activities
                
                self.dataSource.items.append(activities)
                
                self.tableView.reloadData()

            }) { (error: RestError, res: RestResponse?) -> () in
                loginView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        }
    }
    
    func requestAgainTapped() {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("newRequest") as! NewRequestViewController
        controller.request = request
        navigationController?.pushViewController(controller, animated: true)
    }

    /**
     Submit button tapped.
     
     - parameter sender: The sender
     */
    @IBAction func submitButtonTapped(sender: AnyObject) {
        activitytext = activityTextField.text!
        if (base64String != "" && activitytext == "")   {
            activitytext = "Attachment"
        }
        sendWorkInfoRequest()
    }

    /**
    Action button tapped.
    
    - parameter sender: The sender
    */
    @IBAction func actionButtonTapped(sender: AnyObject) {
        RequestChangeUIAlertView.confirmActionOnRequest(request, delegate: self)
    }
    
    /**
    Edit button tapped.
    
    - parameter sender: The sender
    */
    @IBAction func editButtonTapped(sender: AnyObject) {
        if let editingVC = storyboard?.instantiateViewControllerWithIdentifier("edit") as? EditingViewController {
            editingVC.request = request
            navigationController?.pushViewController(editingVC, animated: true)
        }
    }
    
    /**
    *  Note class.
    */
    private class Note  : NSObject {
        /// Represents the note & requested for.
        var note = ""
    }
    
    /**
    *  Create Entry class.
    */
    private class CreateEntry  : NSObject {
        /// Represents the value.
        var value = ""
    }
    
    /**
    *  Reprsents section entity.
    */
    private class Section : NSObject {
        /// Represents section name.
        var name = ""
        /// Represents section items.
        var items: [NSObject] = []
        /// Represents whether the section is collapsed or not.
        var collapsed = false
    }
    
    /**
    Gets all visible items
    
    - returns: the visible items.
    */
    private func getItems() -> [NSObject] {
        var items: [NSObject] = []
        for section in sections {
            items.append(section)
            if !section.collapsed {
                items += section.items
            }
        }
        return items
    }
    
    private func sendWorkInfoRequest()  {
        let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
        loadingView.show()
        api.createWorkInfo(request, text: activitytext, imageName: attachmentImageName, base64String: base64String, callback: { (activity) -> () in
            
            loadingView.terminate()
            
            self.btextViewEdit = true
            self.loadData()
            
            }) { (error: RestError, res: RestResponse?) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        }
    }
    
    
    /*!
    Start observing keyboard will hide and did show events.
    */
    func startObserving() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /*!
    Stops observing
    */
    func stopObserving() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    /*!
    Keyboard did show.
    :param: notification the notification object.
    */
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardSize: CGSize = keyboardFrame.size
        
        UIView.animateWithDuration(0.5, animations:  {
            self.view.frame = CGRectMake(0, (self.view.frame.origin.y - keyboardSize.height), self.view.frame.size.width, self.view.frame.size.height)
        })
    }
    
    /*!
    Keyboard will hide.
    :param: notification the notification object.
    */
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.5, animations:  {
            self.view.frame = CGRectMake(0, (UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height)!), self.view.frame.size.width, self.view.frame.size.height)
        })
    }
    
    /**
    view tap handler
    */
    func viewTapped() {
        self.view.endEditing(true)
    }

    /**
    decode: method to convert base64 string to file
     
    :param parm: The base 64 string
    :param suffix: The file extension
    */
    func decode(parm: String, suffix: String)   {
        let decodedData = NSData(base64EncodedString: parm, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let fileName : String = String(format:"file.%@", suffix)
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileName)
            if (decodedData!.writeToFile(path, atomically: false))  {
                showFileWithPath(path)
            }
        }
    }
    
    /**
    showFileWithPath: show preview of the file
     
    :param path: The file path
    */
    func showFileWithPath(path: String){
        let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(path)
        if isFileFound == true{
            let viewer = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreviewAnimated(true)
        }
    }

    /**
    clearAllFilesFromTempDirectory: clear all type of file from document directory
    */
    func clearAllFilesFromTempDirectory()   {
        
        let fileManager = NSFileManager.defaultManager()
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        do {
            let filePaths = try fileManager.contentsOfDirectoryAtPath(documentDirectoryPath)
            for filePath in filePaths {
                let destinationURLForFile = documentDirectoryPath.stringByAppendingFormat("/%@", filePath)

                try fileManager.removeItemAtPath(destinationURLForFile)
            }
        } catch {
            print("Could not clear folder: \(error)")
        }
    }
    
    /**
     numberOfLinesInLabel: return the number of lines 
     */
    func numberOfLinesForString(string: String, size: CGSize, font: UIFont) -> Int {
        let textStorage = NSTextStorage(string: string, attributes: [NSFontAttributeName: font])
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.textStorage = textStorage
        layoutManager.addTextContainer(textContainer)
        
        var numberOfLines = 0
        var index = 0
        var lineRange : NSRange = NSMakeRange(0, 0)
        for (; index < layoutManager.numberOfGlyphs; numberOfLines++) {
            layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
        }
        
        return numberOfLines
    }
}


extension RequestDetailsViewController : UIAlertViewDelegate {
    
    /**
    Alert view button tapped.
    
    - parameter alertView:   The alert view
    - parameter buttonIndex: The button index
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let newStatus = request.status.nextStatus() where buttonIndex == 1 {

            let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
            loadingView.show()
            api.updateStatus(request, status: newStatus.status, callback: { (request) -> () in
                loadingView.terminate()

                // update the UI
                self.statusLabel.text = request.status.rawValue.localized
                self.statusLabel.textColor = request.status.getColor()
                
                //cparish updated
                //self.colorView.backgroundColor = request.status.getColor()
                self.colorView.backgroundColor = request.status.getBackgroundColor()

                self.updateStatusAction()

            }, errorCallback: { (error, res) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
            })
        }
    }
}

extension RequestDetailsViewController: UITableViewDelegate {

    /**
     Height of a header in section.
     
     - parameter tableView: The table view
     - parameter section: The section number
     
     - returns: the height of a header.
     */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if ((summaryLabel.text!.contains("-")) || (summaryLabel.text!.contains("\n")))   {
                tableviewConstraint?.constant = CGFloat(contentView.frame.size.height - 10)
        }   else    {
            tableviewConstraint?.constant = CGFloat(contentView.frame.size.height)
        }
        return 0.0
    }

    /**
    Height of a row.
    
    - parameter tableView: The table view
    - parameter indexPath: The index path
    
    - returns: the height of a row.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        if item.isKindOfClass(Section.self) {
            let nitem: Section = item as! Section
            //if (summaryLabel.text!.contains("-") && (nitem.name.compare("details".localized) == .OrderedSame))   {
            if ((summaryLabel.frame.size.height > 22.0) && (nitem.name.compare("details".localized) == .OrderedSame))   {
                return 58
            }
            return 48
        } else if item.isKindOfClass(RequestActivity.self) {
            let t = item as? RequestActivity
            var num = UIFont.lightOfSize(16).sizeOfString(t!.text, constrainedToWidth: tableView.bounds.width - 32).height
            num += 58.12
            if (num < 77) {
                num = 77
            }
            return num   //(num + CGFloat(20 * t!.attachedNames.count))
        } else if item.isKindOfClass(RequestAttachActivity.self)  {
            /*let t = item as? RequestAttachActivity
            if (t!.attachedNames.count > 0)  {
                return (77 + CGFloat(20 * t!.attachedNames.count))
            }*/
            return 100
        }   else if item.isKindOfClass(CreateEntry.self) {
            return 80
        }   else if let item = item as? Note {
            return UIFont.lightOfSize(16).sizeOfString(item.note, constrainedToWidth: tableView.bounds.width - 32).height + 30
        }   else if item.isKindOfClass(DetailNotes.self) {
            return 80
        }
        
        return 0
    }
    
    /**
    should highlight row at index path.
    
    - parameter tableView: The table view
    - parameter indexPath: The index path
    
    - returns: true, if should highlight row at index path.
    */
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        return item.isKindOfClass(Section.self)
    }
    
    /**
    row selected.
    
    - parameter tableView: The table view
    - parameter indexPath: The index path
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let section = dataSource.itemAtIndexPath(indexPath) as! Section
        
        let items: [NSObject]
        if section.collapsed {
            section.collapsed = !section.collapsed
            items = getItems()
        } else {
            items = getItems()
            section.collapsed = !section.collapsed
        }
        
        var indexPaths: [NSIndexPath] = []
        for item in section.items {
            let index = items.indexOf(item)!
            indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
        }
        
        dataSource.items = [getItems()]
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        if section.collapsed {
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }
}

extension RequestDetailsViewController : UITextFieldDelegate {
    
    /**
    Text field ended editing.
    
    - parameter textField: The text field
    */
    func textFieldDidEndEditing(textField: UITextField) {
        for item in dataSource.items[0] {
            if let item = item as? CreateEntry {
                item.value = textField.text!
                return
            }
        }
    }
    
    /**
    should text field return.
    
    - parameter textField: The text field
    
    - returns: true if should return.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text!.trimmedString().isEmpty {
            return true
        }
        return true
    }
    
    /**
     should change character in range
     
     Param textfield: The text field
     
     
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool  {
        return true
    }
}

extension RequestDetailsViewController : UITextViewDelegate {
    
    /**
    Should Change Text
    */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool   {
        return true
    }

}

extension RequestDetailsViewController : AttachmentViewDelegate {
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
            attachmentImageName = ""
            self.tableView.reloadData()
        }
        return ""
    }
    
}

extension RequestDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate    {
    
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
                
                attachmentImageName = "asset.jpg"
                attachmentDetails = String(format: "%@ : %.2f MB", attachmentImageName, imageSize)
                
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

class RequestChangeUIAlertView: UIAlertView {
    
    var request: Request!
    var data: AnyObject?
    
    class func confirmActionOnRequest(request: Request, delegate: UIAlertViewDelegate) -> RequestChangeUIAlertView {
        var statusStr = ""
        if let newStatus = request.status.nextStatus()?.status {
            switch newStatus {
            case .Cancelled:
                statusStr = "Cancel"
            case .Assigned:
                if request.status == .Resolved {
                    statusStr = "Assigned"
                }
            default:
                break
            }
        }
        let alert = RequestChangeUIAlertView(
            title: "changeRequestStatus\(statusStr)Title".localized,
            message: "changeRequestStatus\(statusStr)Body".localized,
            delegate: delegate,
            cancelButtonTitle: "changeRequestStatus\(statusStr)Cancel".localized,
            otherButtonTitles: "changeRequestStatus\(statusStr)Confirm".localized)
        alert.request = request
        alert.show()
        return alert
    }
}

extension RequestDetailsViewController: ActivityDetailTableViewCellDelegate {
    /**
    call Download Api
    
    parameter: button tag
    parameter: button
    */
    func callDownloadApi(sender: AnyObject, entity: RequestAttachActivity, activitydetail: ActivityDetailTableViewCell) -> Bool {
        print(__FUNCTION__)
        getAttachmentData(entity)
        return true
    }
    
    /**
     Load data from API
     */
    func getAttachmentData(entity: RequestAttachActivity) {
        let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
        loadingView.show()
        
        api.getAttachmentData(entity.workinfoId!, filename: entity.attachedNames[0], callback: { attachmentData -> () in
            
            loadingView.terminate()
            
            do {

                let suffixString : String! = NSURL(fileURLWithPath: (entity.attachedNames[0])).pathExtension
                self.decode(attachmentData, suffix: suffixString)
                
//                var writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("/Images")
//                writePath = (writePath as NSString).stringByAppendingPathComponent(entity.attachedNames[0])
//                try attachmentData.writeToFile(writePath, atomically: false, encoding: NSUTF8StringEncoding)
                
                /* */
//                let decodedData = NSData(base64EncodedString: attachmentData, options: NSDataBase64DecodingOptions(rawValue: 0))
//                let decodedimage = UIImage(data: decodedData!)
//                UIImageWriteToSavedPhotosAlbum(decodedimage!, nil, nil, nil)

            }
            catch {
                /* error handling here */
            }

            //print ("\(attachmentData)")

        }, errorCallback: { (error, res) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        })
    }

}

extension RequestDetailsViewController : UIDocumentInteractionControllerDelegate    {
    /**
    document interaction controller view controller for preview 
    
    :parmameter controller: The uidocumentinteractioncontroller instance 
    */
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    /**
    document interaction controller did end preview
     
    :parmameter controller: The uidocumentinteractioncontroller instance
    */
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController)    {
        print(__FUNCTION__)
        clearAllFilesFromTempDirectory()
    }
}

class DetailNotes : NSObject    {
    /// Represents the notes
    var notes : String = ""
    /// Represents the requested by text
    var requestedBy : String = ""
    /// Represents the requested for text
    var requestedFor : String = ""
}