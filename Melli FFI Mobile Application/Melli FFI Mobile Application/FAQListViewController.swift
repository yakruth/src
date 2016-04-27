//
//  FAQListViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* FAQs screen
*
* - Author: Nikita Rodin
* :version: 1.1
*
* changes:
* 1.1:
* - new API methods integration
*/
class FAQListViewController: GAITrackedViewController, UISearchBarDelegate {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// table ds
    var dataSource: ArrayDataSource<FAQItem, FAQCell>?
    
    /// filtered items
    var items: [FAQItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "FAQs".localized
        self.searchBar.placeholder = "FAQ_SEARCH_PLACEHOLDER".localized
        
        self.addMenuButton()
       
        let ds = ArrayDataSource<FAQItem, FAQCell>(items: items, cellReuseIdentifier: "cell", staticTopCells: []) { (cell, item, indexPath) -> Void in
            cell.titleLabel.text = item.title
        }
        tableView.dataSource = ds.proxy
        self.dataSource = ds
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "FAQ List" // Google Analytics screen name
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? FAQDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.item = items[indexPath.row]
            }
        }
    }

    // MARK: - search bar delegate
    
    /**
    called when keyboard search button pressed
    
    - parameter searchBar: searchBar instance
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Remove error message view
        for subview in self.tableView.subviews {
            (subview as? ErrorView)?.removeFromSuperview()
        }
        
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        let string = searchBar.text
        
        // Track the event
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("FAQ", action: "Search", label: string, value: nil).build()! as [NSObject : AnyObject])
        
        ServerApi.sharedInstance.searchFAQ(string!, callback: { (json: JSON) -> () in
            loginView.terminate()

            var items = [FAQItem]()
            for item in json.arrayValue {
                items.append(FAQItem.fromJSON(item))
            }

            self.items = items
            self.dataSource?.allItems = [self.items]
            self.tableView.reloadData()
        }) { (error: RestError, res: RestResponse?) -> () in
            if error.getMessage().contains("ERROR (302)") {
                self.items = []
                self.tableView.reloadData()
                ErrorView.show("Error_NoFAQ".localized, inView: self.tableView)
            }
            else {
                error.showError()
            }
            loginView.terminate()
        }
    }
}

extension FAQListViewController : UITableViewDelegate {

    /**
    Table view's row height for row at index path.

    - parameter tableView: The table view parameter.
    - parameter indexPath: The index path parameter.

    - returns: The height of thr row at the passed index path.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = self.dataSource!.itemAtIndexPath(indexPath)

        let font = UIFont(name: "Helvetica-Light", size: 16)!
        let size = font.sizeOfString(item.title, constrainedToWidth: tableView.bounds.width - 66)

        return ceil(size.height) + 60
    }
}

/**
* FAQ cell
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class FAQCell: UITableViewCell {
    
    // outlets
    @IBOutlet weak var titleLabel: UILabel!
}