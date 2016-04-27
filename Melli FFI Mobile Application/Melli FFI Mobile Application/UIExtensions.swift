//
//  UIExtensions.swift
//  Meli FFI Mobile Application
//
//  Created by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
/**
A set of helpful extensions for classes from UIKit
*/

/**
* Methods that help to open common screens
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIViewController {
    
    /**
    Show Survey screen
    */
    func showSurveyScreen(incidentNumber: String, completion: ()->()) {
        let window = UIApplication.sharedApplication().keyWindow
        if let vc = window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("appFeedback") as? AppFeedbackViewController {
            vc.incidentNumber = incidentNumber
            vc.completion = completion
            let navc = UINavigationController(rootViewController: vc)
            navc.navigationBar.translucent = false
            var rootVC = window?.rootViewController
            while rootVC?.presentedViewController != nil {
                rootVC = rootVC?.presentedViewController
            }
            if let navRootVC = rootVC as? UINavigationController,
                let feedbackVC = navRootVC.topViewController as? AppFeedbackViewController {
                    // already presented, skip
                completion()
            } else {
                rootVC?.presentViewController(navc, animated: true, completion: nil)
            }
        }
        else {
            completion()
        }
    }

    /**
    Shows Survey screen randomly.
    The probablity is configured in configuration.plist
    */
    func tryShowSurveyScreen(incidentNumber: String, completion: ()->()) {
        let random = Int.random(100)
        if random < Configuration.sharedConfig.feedbackProbability {
            showSurveyScreen(incidentNumber, completion: completion)
        }
        else {
            completion()
        }
    }
}

/**
* Shortcut methods for UITableView
*
* @author Alexander Volkov
* @version 1.0
*/
extension UITableView {
    
    /**
    Prepares tableView to have zero margins for separator
    and removes extra separators after all rows
    */
    func separatorInsetAndMarginsToZero() {
        let tableView = self
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRectZero);
    }
}