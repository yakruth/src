//
//  ManageSubscriptionsViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/5/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Manage subscriptions screen
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class ManageSubscriptionsViewController: SubmitViewController {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// table ds
    var dataSource: ArrayDataSource<Subscription, SubscriptionCell>?
    
    /// items
    var items: [Subscription] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorInsetAndMarginsToZero()
        // Do any additional setup after loading the view.
        self.title = "subscriptions".localized
        self.addMenuButton()
        
        loadData();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Manage Subscriptions"  // Google Analytics screen name
    }
    
    /**
    loading data
    */
    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        let _eid = AuthenticationUtil.getUserInfo()!.username
        
        ServerApi.sharedInstance.getSubscriptions(_eid , callback: { (json: JSON) -> () in
            
            self.items = Subscription.listFromJson(json)
            
            self.items.sortInPlace {$0.title < $1.title}
            
            ServerApi.sharedInstance.getEnabledSubscriptions(_eid, callback: { (json: JSON) -> () in
                loginView.terminate()
                
                let enabledAlerts: [String] = json.arrayValue.map({$0["ContentLabel"].stringValue})
                for s in self.items {
                    s.value = enabledAlerts.contains(s.title)
                }
                self.displayData();
            }, errorCallback: { (error, res) -> () in
                self.displayData();
                loginView.terminate()
            })
            
            
        }) { (error: RestError, res: RestResponse?) -> () in
            if error.getMessage().contains("ERROR (302)") {
                self.showAlert("Nothing found".localized, title: "Error".localized)
            }
            else {
                error.showError()
            }
            loginView.terminate()
        }
    }
    
    
    func displayData() {
        //display
        let ds = ArrayDataSource<Subscription, SubscriptionCell>(items: self.items, cellReuseIdentifier: "cell", staticTopCells: []) { (cell, item, indexPath) -> Void in
            cell.titleLabel.text = item.title
            cell.switchControl.on = item.value
            //cell.titleLabel.textColor = item.value ? .blackColor() : .lightGrayColor()
            cell.titleLabel.textColor = .blackColor()
            cell.onSwitch = { (value) in
                self.items[indexPath.row].value = value
                self.items[indexPath.row].userChanged = !self.items[indexPath.row].userChanged
                
            }
        }
        self.tableView.dataSource = ds.proxy
        self.dataSource = ds
        self.tableView.reloadData()
        
        //display
        
    }
    
    
    /**
    *  sends data to server asynchronously
    */
    override func sendData(completion: () -> ()) {
        // mock sending
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()

        var isOn: String
        let _eid = AuthenticationUtil.getUserInfo()!.username
        for item in self.items {
          
            if (item.userChanged) {
                ServerApi.sharedInstance.cachedNewsItems = nil
                isOn = item.value ? "Yes" : "No";
                ServerApi.sharedInstance.setSubscriptions2(_eid, contentLabel: item.title, subscriptionFlag: isOn,
                    callback: { () -> () in
                }) { (error:RestError, res: RestResponse?) -> () in
                    error.showError()
                }
            }
        }
        
        loginView.terminate()
        completion()

    }

}

/**
* Subscription cell
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class SubscriptionCell: ZeroMarginsCell {
    
    // outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    /// switch event handler
    var onSwitch: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        switchControl.addTarget(self, action: "switchHandler", forControlEvents: .ValueChanged)
    }
 
    /**
    switch event handler
    */
    func switchHandler() {
        self.onSwitch?(switchControl.on)
    }
    
}