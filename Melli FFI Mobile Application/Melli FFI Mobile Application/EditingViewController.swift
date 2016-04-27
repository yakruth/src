//
//  EditingViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the editing view controller class.

@author mohamede1945, Alexander Volkov
@version 1.0
*
* changes:
* 1.1:
* - Google Analytics support
*/
class EditingViewController: BaseEditingViewController {

    /// the number label
    @IBOutlet weak var numberLabel: UILabel!
    /// the status label
    @IBOutlet weak var statusLabel: UILabel!
    /// the color view
    @IBOutlet weak var colorView: UIView!

    /// Represents the activity section.
    private var activitySection: Section!

    /**
    View did loaded
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "editRequest".localized
        actionButton.setTitle("save".localized, forState: .Normal)


        numberLabel.text = request.incidentId
        statusLabel.text = request.status.rawValue.localized
        statusLabel.textColor = request.status.getColor()
        colorView.backgroundColor = request.status.getColor()

        tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.registerNib(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "label")
        tableView.registerNib(UINib(nibName: "CollapsibleTableViewCell", bundle: nil), forCellReuseIdentifier: "header")

        let activityConfigurer = GeneralCellConfigurer<RequestActivity, LabelTableViewCell> { (cell, entity, _) -> Void in
            cell.configure(entity)
        }

        let sectionConfigurer = GeneralCellConfigurer<Section, CollapsibleTableViewCell> { (cell, entity, _) -> Void in
            cell.nameLabel.text = entity.name
            cell.arrowImage.image = UIImage(named: entity.collapsed ? "arrow-down" : "arrow-up")
        }

        activitySection = Section()
        activitySection.name = "activity".localized
        activitySection.items = request.activities

        dataSource = DisjointArrayDataSource(items: [getItems()], cellConfigurers: [
            (type: RequestActivity.self, reuseIdentifier: "label", configurer: activityConfigurer),
            (type: Section.self, reuseIdentifier: "header", configurer: sectionConfigurer),
            (type: NSString.self, reuseIdentifier: "summary", configurer: summaryNotesConfigurer)])

        tableView.dataSource = dataSource
    }
    
    /**
    View will appear.
    
    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Editing Screen"
    }

    /**
     Cancel button tapped.
     */
    func cancelButtonTapped() {
        UIAlertView(
            title: "cancelRequestEditTitle".localized,
            message: "cancelRequestEditBody".localized,
            delegate: self,
            cancelButtonTitle: "cancelRequestEditCancel".localized,
            otherButtonTitles: "cancelRequestEditConfirm".localized).show()
    }

    /**
    Action buttno tapped.

    - parameter sender: The sender
    */
    @IBAction func actionButtonTapped(sender: AnyObject) {
        if validate() {
            // modify the request
            request.template = template
            request.summary = summaryText
            request.notes = notesText
            request.urgency = urgency
            navigateToConfirmation(request)
        }
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
        items.append(NSString()) // dummy object
        items.append(activitySection)
        if !activitySection.collapsed {
            items += activitySection.items
        }
        return items
    }
}

extension EditingViewController: UITableViewDelegate {

    /**
    height for row at index path.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the height for index path.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        if item.isKindOfClass(Section.self) {
            return 56
        } else if item.isKindOfClass(RequestActivity.self) {
            return 77
        } else if item.isKindOfClass(NSString.self) {
            return 396
        }
        return 0
    }

    /**
    should highlight row at index path.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: true if should highlight.
    */
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        return item.isKindOfClass(Section.self)
    }

    /**
    Row has been selected.

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