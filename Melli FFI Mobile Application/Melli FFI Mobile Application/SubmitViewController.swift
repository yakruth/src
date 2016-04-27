//
//  SubmitViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/5/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

class SubmitViewController: GAITrackedViewController {

    // MARK: - actions
    
    /**
    submit tap handler
    
    - parameter sender: the button
    */
    @IBAction func submitTapped(sender: AnyObject) {
        if self.validate() {
            self.sendData {
                self.navigateTo(.Home)
                MenuViewControllerSingleton?.setSelected(.Home)
            }
        }
    }
    
    /**
    cancel tap handler
    
    - parameter sender: the button
    */
    @IBAction func cancelTapped(sender: AnyObject) {
        self.navigateTo(.Home)
        MenuViewControllerSingleton?.setSelected(.Home)
    }
    
    /**
    *  sends text data to server asynchronously
    */
    func sendData(completion: () -> ()) {
        // mock sending
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            loginView.terminate()
            completion()
        }
    }
    
    /**
    Validates form, messages user about any occured error
    
    - returns: true, if user can proceed
    */
    func validate() -> Bool {
        return true
    }
}
