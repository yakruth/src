//
//  ConfirmationViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the confirmation view controller class.

@author mohamede1945
@version 1.0
*/
class ConfirmationViewController: GAITrackedViewController {

    /// Represents the request submitted label.
    @IBOutlet weak var requestSubmittedLabel: UILabel!
    /// Represents the number label.
    @IBOutlet weak var numberLabel: UILabel!
    /// Represents the thanks label.
    @IBOutlet weak var thanksLabel: UILabel!
    /// Represents the home button.
    @IBOutlet weak var homeButton: UIButton!
    /// Represents the detail button.
    @IBOutlet weak var detailButton: UIButton!

    /// Represents the request.
    var request: Request!
    
    var incidentNumber: String {
        get {
            /* "-" is added to allow demonstrating a success Survey submittion
            as the service required not empty incidentNumber value
            */
            if request.incidentId.isEmpty {
                return "-"
            }
            return request.incidentId
        }
    }

    /**
    View did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "newRequest".localized
        addMenuButton()
        requestSubmittedLabel.text = "requestSubmittedText".localized
        thanksLabel.text = "requestSubmittedThanks".localized
        homeButton.setTitle("home".localized, forState: .Normal)
        detailButton.setTitle("requestSubmittedReviewDetail".localized, forState: .Normal)

        numberLabel.text = request.incidentId
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "New Request Confirmation"  // Google Analytics screen name
    }
    

    /**
    Detail button tapped.

    - parameter sender: The sender
    */
    @IBAction func detailTapped(sender: AnyObject) {
        self.tryShowSurveyScreen(incidentNumber) {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("details") as? RequestDetailsViewController {
                vc.request = self.request
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    /**
    Home button tapped.

    - parameter sender: The sender
    */
    @IBAction func homeTapped(sender: AnyObject) {
        self.tryShowSurveyScreen(incidentNumber) {
            // navigate to home
            if let slideVC = self.slideMenuController,
                let menuVC = slideVC.sideController as? MenuViewController,
                let controller = menuVC.createContentControllerForItem(.Home) {
                    slideVC.setContentViewController(controller)
                    menuVC.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0),
                        animated: false, scrollPosition: .Top)
                    
                    
            }
        }
    }

}
