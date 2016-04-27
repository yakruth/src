//
//  HomeViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the home view controller class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - intergration with server API
*/
class HomeViewController: GAITrackedViewController {

    /// Represents the self service label.
    @IBOutlet weak var selfServiceLabel: UILabel!
    /// Represents the the request support label.
    @IBOutlet weak var requestSupportLabel: UILabel!

    /// Represents the the requests button.
    @IBOutlet weak var requestsButton: UIButton!
    /// Represents the the requests button.
    @IBOutlet weak var assetsButton: UIButton!
    /// Represents the the news button.
    @IBOutlet weak var newsButton: UIButton!
    /// Represents the faq's button.
    @IBOutlet weak var faqsButton: UIButton!

    /// Represents the create label.
    @IBOutlet weak var createLabel: UILabel!
    /// Represents the chat label.
    @IBOutlet weak var chatLabel: UILabel!
    /// Represents the email label.
    @IBOutlet weak var emailLabel: UILabel!
    /// Represents the schedule label.
    @IBOutlet weak var scheduleLabel: UILabel!
    /// Represents the call label.
    @IBOutlet weak var callLabel: UILabel!

    /// Represents the requests count label.
    @IBOutlet weak var requestsCountLabel: RoundedLabel!
    /// Represents the requests count label.
    @IBOutlet weak var assetsCountLabel: RoundedLabel!
    /// Represents the news&alerts count label.
    @IBOutlet weak var newsCountLabel: RoundedLabel!
    /// Represents the faq count label.
    @IBOutlet weak var faqCountLabel: RoundedLabel!
    /// API
    let api = AuthApi()

    /// the list of items.
    let items : [Int: MenuViewController.MenuItem] = [1: .MyRequests, 2: .MyAssets, 3: .News, 4: .FAQs, 5: .NewRequest,
        6: .NewChat, 7: .NewEmail, 8: .NewSchedule, 9: .NewCall]

    /**
    View has been loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        addMenuButton()
        navigationItem.titleView = UIImageView(image: UIImage(named: "home-logo"))

        let logout = createNavigationItem("logout".localized)
        (logout.customView as! UIButton).addTarget(self, action: "logoutTapped", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = logout

        selfServiceLabel.text = "selfService".localized
        requestSupportLabel.text = "requestSupport".localized
        requestsButton.setTitle("myRequests".localized, forState: .Normal)
        assetsButton.setTitle("myAssets".localized, forState: .Normal)
        newsButton.setTitle("newsAlerts".localized, forState: .Normal)
        faqsButton.setTitle("faqs".localized, forState: .Normal)

        createLabel.text = "createRequestHome".localized
        chatLabel.text = "chatHome".localized
        emailLabel.text = "emailHome".localized
        scheduleLabel.text = "scheduleHome".localized
        callLabel.text = "callHome".localized
    }

    /**
    logout tapped
    */
    func logoutTapped() {
        ServerApi.sharedInstance.clearCache();
        
        AuthenticationUtil.logout { () -> () in
            self.logoutUI()
        }
    }

    /**
    view will appear.

    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Home Screen" // Google Analytics screen name
        
        // Update counter for "My Requests"
        requestsCountLabel.hidden = true
        ServerApi.sharedInstance.getIncidentsListParsed(assetCI: "", forseLoad: false, callback: { (list: [Request]) -> () in
            if list.count > 0 {
                self.requestsCountLabel.text = "\(list.count)"
                self.requestsCountLabel.hidden = false
            }
        }) { (error: RestError, res: RestResponse?) -> () in
            print("ERROR: \(error.getMessage())")
        }
        
        /// Update news count
        newsCountLabel.hidden = true
        
        let _sbg = AuthenticationUtil.getUserInfo()!.sbg
        let _eid = AuthenticationUtil.getUserInfo()!.username

        ServerApi.sharedInstance.getNewsAndAlertsParsed(_sbg, eid: _eid , callback: { (newsItems: [NewsAlertItem]) -> () in
            let newsCount = newsItems.count
            
            if newsCount > 0 {
                self.newsCountLabel.hidden = false
                self.newsCountLabel.text = "\(newsCount)"
            }
            
        }) { (error: RestError, res: RestResponse?) -> () in
            print("ERROR: \(error.getMessage())")
        }
        
        /// Update asset count
        assetsCountLabel.hidden = true
        
        ServerApi.sharedInstance.getAssetsCount(_eid , callback: { (count: String) -> () in
            let numCount = Int(count)
            
            if (numCount > 0)   {
                self.assetsCountLabel.text = "\(count)"
                self.assetsCountLabel.hidden = false
            }
            
            }) { (error: RestError, res: RestResponse?) -> () in
                print("ERROR: \(error.getMessage())")
        }

    }

    /**
    navigation button tapped.

    - parameter sender: The sender
    */
    @IBAction func navigationButtonTapped(sender: UIButton) {
        let menuItem = items[sender.tag]!
        navigateTo(menuItem)
        MenuViewControllerSingleton?.setSelected(menuItem)
    }
}