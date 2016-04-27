//
//  NewsDetailViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* News & alerts details screen
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class NewsDetailViewController: GAITrackedViewController {

    // outlets
    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UILabel!
    
    /// item
    var item: NewsAlertItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "News Details".localized
        self.addBackItem()
        
        titleLabel.text = item.title
        dateLabel.text = item.availabilityDate.formattedForNews
        textView.text = item.text
        
        if item.isAlert {
            icon.setImage(UIImage(named: "menu-faq")!, forState: .Normal)
            icon.tintColor = UIColor(r: 232, g: 52, b: 23)
        } else
        {
            icon.setImage(UIImage(named: "menu-news")!, forState: .Normal)
            icon.tintColor = UIColor(r: 74, g: 143, b: 222)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "News Details"  // Google Analytics screen name
    }

}
