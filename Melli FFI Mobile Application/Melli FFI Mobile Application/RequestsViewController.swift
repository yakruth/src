//
//  RequestsViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/16/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the requests view controller class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - intergration with server API
*/
class RequestsViewController: GAITrackedViewController {

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the data source.
    var dataSource: ArrayDataSource<Request, RequestTableViewCell>!

    /// API
    let api = ServerApi.sharedInstance
    
    /**
    View did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "myRequests".localized
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
    
    /**
    Load data from API
    */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        api.getIncidentsListParsed(assetCI: "", forseLoad: true, callback: { (list: [Request]) -> () in
            
            loginView.terminate()
            /*
            list.sort { (req1, req2) -> Bool in
                if req1.status.order == req2.status.order {
                    return req1.incidentId.compare(req2.incidentId) == .OrderedAscending
                }
                return req1.status.order < req2.status.order
            }
            */
            self.dataSource.allItems = [list]
            self.tableView.reloadData()
            self.updateNumberOfRequests()
            
        }) { (error: RestError, response: RestResponse?) -> () in
            loginView.terminate()
            ErrorView.show("Error_NoRequest".localized, inView: self.view)
        }
    }
    
    /**
    Update number of requests in the table header
    */
    func updateNumberOfRequests() {
        let headerLabel = tableView.tableHeaderView as? UILabel
        if dataSource.allItems.count > 0 {
            headerLabel?.text = "  \(dataSource.allItems[0].count) Requests"
        }
        else {
            headerLabel?.text = ""
        }
    }

    /**
    view will appear.

    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Requests List Screen" // Google Analytics screen name
        loadData()
    }

    /**
    Navigate to news.

    - parameter sender: The sender
    */
    @IBAction func navigateToNews(sender: AnyObject) {
        navigateTo(.News)
    }
}

extension RequestsViewController : RequestTableViewCellDelegate, UIAlertViewDelegate {
    /**
    request table view cell tapped.

    - parameter requestTableViewCell: The request table view cell
    */
    func requestTableViewCellActionTapped(requestTableViewCell: RequestTableViewCell) {
        if let indexPath = tableView.indexPathForCell(requestTableViewCell) {
            let request = dataSource.itemAtIndexPath(indexPath)
            let alert = RequestChangeUIAlertView.confirmActionOnRequest(request, delegate: self)
            alert.data = indexPath
        }
    }
    
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

extension RequestsViewController : UITableViewDelegate {

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
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RequestTableViewCell,
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
        if let detailsVC = storyboard?.instantiateViewControllerWithIdentifier("details") as? RequestDetailsViewController {
            detailsVC.request = dataSource.itemAtIndexPath(indexPath)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
