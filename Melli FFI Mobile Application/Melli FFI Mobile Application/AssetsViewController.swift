//
//  AssetsViewController.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 1/6/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

import UIKit

class AssetsViewController: GAITrackedViewController {
    
    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the data source.
    var dataSource: ArrayDataSource<Assets, MyAssetsTableViewCell>!

    /// API
    let api = ServerApi.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "myAssets".localized
        
        addMenuButton()
        
        dataSource = ArrayDataSource(items: [[]], cellReuseIdentifier: "cell",
            configureClosure: { (cell, entity, _) -> Void in
                cell.delegate = self
                cell.configure(entity)
        })
        tableView.dataSource = dataSource.proxy

        let headerLabel = UILabel()
        headerLabel.font = UIFont.lightOfSize(16)
        headerLabel.textColor = UIColor(r: 32, g: 41, b: 58)
        
        let shiftX: CGFloat = 11
        headerLabel.frame = CGRect(x: shiftX, y: 0, width: UIScreen.mainScreen().bounds.width - shiftX, height: 40)
        tableView.tableHeaderView = headerLabel

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Assets List Screen"  // Google Analytics screen name
        
        loadData()
    }
    
    /**
     Load data from API
     */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        api.getAssetsListParsed(Callback: { (list: [Assets]) -> () in
            
            loginView.terminate()

            self.dataSource.allItems = [list]
            self.tableView.reloadData()
            self.updateNumberOfRequests()
            
            }) { (error: RestError, response: RestResponse?) -> () in
                loginView.terminate()
                ErrorView.show("Error_NoAsset".localized, inView: self.view)
        }
    }

    /**
     Update number of requests in the table header
     */
    func updateNumberOfRequests() {
        let headerLabel = tableView.tableHeaderView as? UILabel
        if dataSource.allItems.count > 0 {
            headerLabel?.text = "  \(dataSource.allItems[0].count) Assets"
        }
        else {
            headerLabel?.text = ""
        }
    }

}

extension AssetsViewController : MyAssetsTableViewCellDelegate, UIAlertViewDelegate {
    /**
     request table view cell tapped.
     
     - parameter requestTableViewCell: The request table view cell
     */
    func assetsTableViewCellActionTapped(requestTableViewCell: MyAssetsTableViewCell) {
        if let indexPath = tableView.indexPathForCell(requestTableViewCell) {
            let request = dataSource.itemAtIndexPath(indexPath)
            let alert = AssetChangeUIAlertView.confirmActionOnRequest(request, delegate: self)
            alert.data = indexPath
        }
    }
    
    /**
     button tapped
     
     - parameter requestTableViewCell: The request table view cell
     - parameter sender: The table view cell button
    */
    func templateButtonTapped(assetsTableViewCell: MyAssetsTableViewCell, sender: AnyObject)    {
        if let newAssetReqVC = storyboard?.instantiateViewControllerWithIdentifier("assertrequest") as? NewAssetRequestViewController {
            newAssetReqVC.assetsEntity = assetsTableViewCell.assetEntity
            navigationController?.pushViewController(newAssetReqVC, animated: false)
        }
    }

    /**
    alertview
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let request = (alertView as? RequestChangeUIAlertView)?.request where buttonIndex == 1 {
            if let indexPath = (alertView as? RequestChangeUIAlertView)?.data as? NSIndexPath {
                if let newStatus = request.status.nextStatus() {
                    
                    let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
                    loadingView.show()
                    api.updateStatus(request, status: newStatus.status, callback: { (request) -> () in
                        loadingView.terminate()
                        
                        // update the UI
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        
                        
                        }, errorCallback: { (error, res) -> () in
                            loadingView.terminate()
                            ErrorView.show(error.getMessage(), inView: self.view)
                    })
                }
            }
        }
    }
}

extension AssetsViewController : UITableViewDelegate {
    
    /**
     Scroll view will begin dragging.
     
     - parameter scrollView: The scroll view
     */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }
    
    /**
     Should highlight a row.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     
     - returns: true if should highlight a row, otherwise no.
     */
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MyAssetsTableViewCell,
            let scrollView = cell.scrollView where scrollView.contentOffset.x != 0 {
                return false
        }
        return true
    }

    /**
     Did select row at index path.
     
     - parameter tableView: The table view
     - parameter indexPath: The index path
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let detailsVC = storyboard?.instantiateViewControllerWithIdentifier("assetDetails") as? AssetDetailsViewController {
            detailsVC.assetsEntity = self.dataSource.itemAtIndexPath(indexPath)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}

