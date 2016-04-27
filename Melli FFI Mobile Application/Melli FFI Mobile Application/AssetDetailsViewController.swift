//
//  AssetDetailsViewController.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 1/6/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

class AssetDetailsViewController: KeyboardViewController {
    
    /// Represents the label.
    @IBOutlet weak var assetDetailsLabel: UILabel!

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the data source.
    var dataSource: DisjointArrayDataSource!
    
    /// Represents the assets object
    var assetsEntity = Assets()
    
    /// Represents the sections.
    private var sections: [Section] = []

    /// Represents the sections.
    private let activitySection = Section()

    /// Represents the date formatter.
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        //formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "assetdetails".localized
        
        addBackItem()
        
        configure()
        
        activitySection.name = "Requests".localized
        
        self.sections = [activitySection]

        tableView.registerNib(UINib(nibName: "CollapsibleTableViewCell", bundle: nil), forCellReuseIdentifier: "header")
        tableView.registerNib(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "label")

        let sectionConfigurer = GeneralCellConfigurer<Section, CollapsibleTableViewCell> { (cell, entity, _) -> Void in
            cell.nameLabel.text = entity.name
            cell.arrowImage.image = UIImage(named: entity.collapsed ? "arrow-down" : "arrow-up")
        }
        let activityConfigurer = GeneralCellConfigurer<RequestActivity, LabelTableViewCell> { (cell, entity, _) -> Void in
            cell.configure(entity)
        }
        let entryConfigurer = GeneralCellConfigurer<Request, AssetDetailTableViewCell> { (cell, entity, _) -> Void in
            cell.configure(entity)
        }

        dataSource = DisjointArrayDataSource(items: [getItems()], cellConfigurers: [
            (type: RequestActivity.self, reuseIdentifier: "label", configurer: activityConfigurer),
            (type: Section.self, reuseIdentifier: "header", configurer: sectionConfigurer),
            (type: Request.self, reuseIdentifier: "assetentry", configurer: entryConfigurer)])
        
        tableView.dataSource = dataSource

        loadData()
    }
    
    /**
     Setup Google Analytics screen name when appear.
     
     - parameter animated: animation flag
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Asset Details Screen" // Google Analytics screen name
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: animated)
            }
        }
        self.tableView.reloadData()
    }

    func configure()    {
        
        let ciName = NSMutableAttributedString(string: "\(assetsEntity.ciName)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let item = NSMutableAttributedString(string: "\n\(assetsEntity.item)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let manufacturerName = NSAttributedString(string: "\n\(assetsEntity.manufacturerName)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let productName = NSAttributedString(string: "\n\(assetsEntity.productName)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let versionNumber = NSAttributedString(string: "\n\(assetsEntity.versionNumber)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let operatingSystem = NSAttributedString(string: "\n\(assetsEntity.operatingSystem)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        let date = AssetDetailsViewController.formatter.stringFromDate(assetsEntity.endOfLeaseDate)
        let endofLease = NSAttributedString(string: "\nEnd of Lease : \(date)",
            attributes: [NSForegroundColorAttributeName: UIColor(r: 32, g: 41, b: 58)])
        ciName.appendAttributedString(item)
        ciName.appendAttributedString(manufacturerName)
        ciName.appendAttributedString(productName)
        ciName.appendAttributedString(versionNumber)
        ciName.appendAttributedString(operatingSystem)
        ciName.appendAttributedString(endofLease)
        assetDetailsLabel.text = nil
        assetDetailsLabel.attributedText = ciName
        
    }
    

    /**
     Load data from API
     */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        ServerApi.sharedInstance.getIncidentsListParsed(assetCI: assetsEntity.ciName, forseLoad: true, callback: { (list: [Request]) -> () in
            
            loginView.terminate()

            self.activitySection.items += list as [NSObject]

            self.dataSource.items = [self.getItems()]

            self.tableView.reloadData()
            
            }) { (error: RestError, response: RestResponse?) -> () in
                loginView.terminate()
                //ErrorView.show("Error_NoRequest".localized, inView: self.view)
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
        for section in sections {
            items.append(section)
            if !section.collapsed {
                items += section.items
            }
        }
        return items
    }

    /**

    */
    @IBAction func assetDetailButtonAction(sender: AnyObject)    {
        if let newAssetReqVC = storyboard?.instantiateViewControllerWithIdentifier("assertrequest") as? NewAssetRequestViewController {
            newAssetReqVC.assetsEntity = assetsEntity
            navigationController?.pushViewController(newAssetReqVC, animated: false)
        }
    }
}


extension AssetDetailsViewController: UITableViewDelegate {
    
    /**
     Height of a row.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     
     - returns: the height of a row.
     */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        if item.isKindOfClass(Section.self) {
            return 56
        }         
        return 60
    }
    
    /**
     should highlight row at index path.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     
     - returns: true, if should highlight row at index path.
     */
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)
        if item.isKindOfClass(Request.self) {
            return true
        }
        return item.isKindOfClass(Section.self)
    }
    
    /**
     row selected.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item: AnyObject = dataSource.itemAtIndexPath(indexPath)

        if item.isKindOfClass(Request.self) {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("details") as? RequestDetailsViewController {
                vc.request = item as! Request
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }   else {
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
}

extension AssetDetailsViewController: CategorySelectionViewControllerDelegate {
    func didChooseTemplate(template: TemplateLeaf)  {
        
    }
}

class AssetChangeUIAlertView: UIAlertView {
    
    var request: Assets!
    var data: AnyObject?
    
    class func confirmActionOnRequest(request: Assets, delegate: UIAlertViewDelegate) -> AssetChangeUIAlertView {
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
        let alert = AssetChangeUIAlertView(
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
