//
//  NewsAlertsViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* News & alerts list screen
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class NewsAlertsViewController: GAITrackedViewController {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// table ds
    var dataSource: ArrayDataSource<NewsAlertItem, NewsCell>?
    
    /// items
    var items: [NewsAlertItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "News & Alerts".localized
        self.addMenuButton()
    

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "News & Alerts"  // Google Analytics screen name
        
        loadData();
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? NewsDetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.item = items[indexPath.row]
            }
        }
    }
    
    //cp
    
    /**
    called when keyboard search button pressed
    
    - parameter searchBar: searchBar instance
    */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        let _eid = AuthenticationUtil.getUserInfo()!.username
        let _sbg = AuthenticationUtil.getUserInfo()!.sbg
        
        ServerApi.sharedInstance.getNewsAndAlertsParsed(_sbg, eid: _eid, forseLoad: true, callback: { (newsItems: [NewsAlertItem]) -> () in
            loginView.terminate()

            self.items = newsItems
          
            if self.items.isEmpty {
                ErrorView.show("Error_NoNews".localized, inView: self.view)
            } else {
                let ds = ArrayDataSource<NewsAlertItem, NewsCell>(items: self.items, cellReuseIdentifier: "cell", staticTopCells: []) { (cell, item, indexPath) -> Void in
                    cell.titleLabel.text = item.title
                    cell.dateLabel.text = item.availabilityDate.formattedForNews
                    cell.textView.text = item.text
                    
                    if item.isAlert {
                        cell.icon.setImage(UIImage(named: "menu-faq")!, forState: .Normal)
                        cell.icon.tintColor = UIColor(r: 232, g: 52, b: 23)
                    } else
                    {
                        cell.icon.setImage(UIImage(named: "menu-news")!, forState: .Normal)
                        cell.icon.tintColor = UIColor(r: 74, g: 143, b: 222)
                    }
                }
                self.tableView.dataSource = ds.proxy
                self.dataSource = ds
                self.tableView.reloadData()
            }
        }) { (error: RestError, res: RestResponse?) -> () in
            if error.getMessage().contains("ERROR (302)") {
                ErrorView.show("Error_NoNews".localized, inView: self.view)
            }
            else {
                error.showError()
            }
        }

    }

    //cp

}

/**
* News cell
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class NewsCell: UITableViewCell {
    
    // outlets
    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UILabel!
    
}

/**
* extension for convenient date formatting
*
* - Author: Nikita Rodin
* :version: 1.0
*/
extension NSDate {
    
    /// formatted date
    var formattedForNews: String {
        struct Static {
            static var dateFormatter: NSDateFormatter = {
                let f = NSDateFormatter()
                //f.dateFormat = "EEE, MMM dd, yyyy '|' hh:mm a"
                f.dateFormat = "EEE, MMM dd, yyyy"
                return f
                }()
            static var timeFormatter: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = " '|' hh:mm a"
                return f
                }()
        }
        
        let time = -self.timeIntervalSinceNow
        switch time {
        case 0..<3600*24:
            return "Today".localized
        case 3600*24..<3600*24*2:
            return "Yesterday".localized
        default:
            return Static.dateFormatter.stringFromDate(self)
        }
    }
    
}