//
//  NewRequestViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the new request view controller class.

@author mohamede1945, Alexander Volkov
@version 1.2
*
* changes:
* 1.1:
* - integration with server API
* 1.2:
* - Survey screen opening
*/
class NewRequestViewController: BaseEditingViewController {

    /// API
    let api = ServerApi.sharedInstance

    /**
    View did load.
    */
    override func viewDidLoad() {
        if request == nil {
            request = Request()
        }
        super.viewDidLoad()
        title = "newRequest".localized
        actionButton.setTitle("sendRequest".localized, forState: .Normal)

        let headerConfigurer = GeneralCellConfigurer<NSDate, NewRequestHeaderTableViewCell> {[weak self] (cell, _, _) -> Void in
            cell.headerLabel.text = self?.template == nil ? "categorySelectionEmpty".localized : "categorySelectionSelected".localized
            cell.dropDownView.textField.tag = 20
            cell.dropDownView.textField.delegate = self
            cell.dropDownView.textField.text = self?.template?.name ?? ""
        }

        let footerConfigurer = GeneralCellConfigurer<NSData, LabelTableViewCell> { (cell, _, _) -> Void in
            cell.label.text = "requestIncident".localized
        }

        dataSource = DisjointArrayDataSource(items: [[NSDate(), NSString(), NSData()]], cellConfigurers: [
            (type: NSDate.self, reuseIdentifier: "header", configurer: headerConfigurer),
            (type: NSData.self, reuseIdentifier: "label", configurer: footerConfigurer),
            (type: NSString.self, reuseIdentifier: "summary", configurer: summaryNotesConfigurer)])

        tableView.dataSource = dataSource
    }
    
    /**
    View will appear.
    
    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "New Request Screen"
    }

    /**
     Cancel button tapped.
     */
    func cancelButtonTapped() {
        UIAlertView(
            title: "cancelRequestNewTitle".localized,
            message: "cancelRequestNewBody".localized,
            delegate: self,
            cancelButtonTitle: "cancelRequestNewCancel".localized,
            otherButtonTitles: "cancelRequestNewConfirm".localized).show()
    }

    /**
    Action button tapped.

    - parameter sender: The sender
    */
    @IBAction func actionButtonTapped(sender: AnyObject) {
        if validate() {
            let request = Request()
            request.template = template
            request.summary = summaryText
            request.notes = notesText
            request.urgency = urgency
            request.attachedImageName = attachmentImageName
            request.base64String = base64String
            request.workInfoSummary = actvityEntryText
            request.requestedEID = requestedForEid
            request.requestedBy = AuthenticationUtil.getUserInfo()?.getFullName() ?? ""
            request.requestedFor = requestedName
            
            if (actvityEntryText == "Create Activity Entry" && base64String != "")   {
                request.workInfoSummary = "Attachment"
            }
            
            let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
            loginView.show()
            api.createRequest(request, callback: { (json: JSON) -> () in
                loginView.terminate()
                
                // Manually change the status after success saving
                request.status = .Assigned
                
                self.navigateToConfirmation(request)
            }, errorCallback: { (error: RestError, response: RestResponse?) -> () in
                loginView.terminate()
                error.showError()
            })
        }
    }

    /**
    Text field should being editing.

    - parameter textField: The text field

    - returns: true if should.
    */
    override func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag != 20 {
            return super.textFieldShouldBeginEditing(textField)
        } else {
            // open category selection
            if let categoryVC = storyboard?.instantiateViewControllerWithIdentifier("categorySelection") as? CategorySelectionViewController {
                categoryVC.delegate = self
                navigationController?.pushViewController(categoryVC, animated: false)
            }
            return false
        }
    }
    
}

extension NewRequestViewController : CategorySelectionViewControllerDelegate {
    /**
    Did choose category.

    - parameter category: The category
    */
    func didChooseTemplate(template: TemplateLeaf) {
        // selected the same template
        if let currentTemplate = self.template where currentTemplate.instanceId == template.instanceId {
            return
        }

        // set the template
        self.template = template

        // if generic --> blank summary
        if template.isGenericTemplate() {
            summaryText = ""
        } else {
            // set the summary
            summaryText = template.getTemplateBranchNames().joinWithSeparator(" ")
            
            //Added by Manjunath on 28/10/2015
            if summaryText.rangeOfString("Favorites") != nil    {
                summaryText = summaryText.chopPrefix(10)
            }
            //End of Addition
        }

        tableView.reloadData() /* Added by H146574: Header was not visible after selection */
        
        // reload the summary and template cells
//        var reloadIndexPaths = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)]
//        tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .Automatic)

        // remove category creation
        navigationController?.popToViewController(self, animated: true)
    }
    
}

//Added by Manjunath on 28/10/2015
/*extension String    {
    func chopPrefix(count: Int = 1) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(count))
    }
}*/
//End of Addition

extension NewRequestViewController: UITableViewDelegate {

    /**
    Height of a row.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the height of a row.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        if item.isKindOfClass(NSDate.self) {
            return 107
        } else if item.isKindOfClass(NSData.self) {
            let font = UIFont.lightOfSize(13)
            let size = font.sizeOfString("requestIncident".localized, constrainedToWidth: tableView.bounds.width - 45)
            return size.height + 30
        } else if item.isKindOfClass(NSString.self) {
            return 590
        }
        return 0
    }
}