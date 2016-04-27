//
//  AppFeedbackViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/5/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/// the height of the keyboard
let keyboardHeight: CGFloat = 400

/**
* Randomly appearing app feedback screen
*
* - Author: Nikita Rodin
* :version: 1.1
*
* changes:
* 1.1:
* - new API methods integration
*/
class AppFeedbackViewController: SubmitViewController {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
     /// related request number
    var incidentNumber: String!
    
    /// table ds
    var dataSource: ArrayDataSource<AppFeedbackEntry, AppFeedbackCell>?
    
    /// items
    var items: [AppFeedbackEntry] = []
    
    /// Action after closed
    var completion: (()->())!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Get Feedback".localized

        self.submitButton.enabled = false
        loadData()
    }
    
    /**
    Load questions from the server
    */
    func loadData() {
        loadingIndicator.startAnimating()
        ServerApi.sharedInstance.getSurveyQuestions({ (json: JSON) -> () in
            var items = [AppFeedbackEntry]()
            var i = 0
            while(true) {
                i++
                if let question = json[0]["Question\(i)"].string {
                    items.append(AppFeedbackEntry(title: question))
                }
                else {
                    break
                }
            }
            items.append(AppFeedbackEntry(title: "Comments".localized))
            self.items = items
            
            let ds = AppFeedbackDataSource<AppFeedbackEntry, AppFeedbackCell>(items: self.items, cellReuseIdentifier: "cell", staticTopCells: []) { (cell, item, indexPath) -> Void in
                cell.numberLabel.text = "\(indexPath.row+1)."
                cell.titleLabel.text = item.title
                cell.segmentControl.selectedSegmentIndex = item.answer ?? -1
                cell.onSwitch = { (index) in
                    self.items[indexPath.row].answer = index
                    
                    self.submitButton.enabled = self.validateWithAlert(false)
                }
            }
            ds.viewController = self
            self.tableView.dataSource = ds.proxy
            self.dataSource = ds
            self.loadingIndicator.stopAnimating()
            self.tableView.reloadData()
        }, errorCallback: { (error: RestError, res: RestResponse?) -> () in
            self.loadingIndicator.stopAnimating()
            error.showError()
        })
    }

    // MARK: - actions
    
    override func submitTapped(sender: AnyObject) {
        if self.validate() {
            self.sendData {
                let navc = (self.presentingViewController as? SlideMenuViewController)?.contentController as? UINavigationController
                navc?.topViewController!.navigateTo(.Home)
                MenuViewControllerSingleton?.setSelected(.Home)
                self.dismissViewControllerAnimated(true, completion: self.completion)
            }
        }
    }
    
    /**
    *  sends data to server asynchronously
    */
    override func sendData(completion: () -> ()) {
        // mock sending
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        ServerApi.sharedInstance.submitSurveryData(incidentNumber, data: self.items, callback: { () -> () in
            loginView.terminate()
            completion()
        }) { (error:RestError, res: RestResponse?) -> () in
            error.showError()
            loginView.terminate()
        }
    }
    
    override func cancelTapped(sender: AnyObject) {
        let navc = (self.presentingViewController as? SlideMenuViewController)?.contentController as? UINavigationController
        navc?.topViewController!.navigateTo(.Home)
        MenuViewControllerSingleton?.setSelected(.Home)
        self.dismissViewControllerAnimated(true, completion: completion)
    }
    
    override func validate() -> Bool {
        return validateWithAlert(true)
    }
    
    func validateWithAlert(needToShowAlert: Bool) -> Bool {
        for item in items {
            if item.answer == nil && (item.comment ?? "").isEmpty {
                if needToShowAlert {
                    self.showAlert("Please, answer all questions".localized)
                }
                return false
            }
        }
        
        return true
    }

    /**
    Add keyboard listeners
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "App Feedback" // Google Analytics screen name

        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Remove listeners
    */
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Handle keyboard opening
    */
    func keyboardWillShow(notification: AnyObject) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    
    /**
    Handle keyboard closing
    */
    func keyboardWillHide(notification: AnyObject) {
        tableView.contentInset = UIEdgeInsetsZero
    }
}

/**
* App feedback cell
*
* - Author: Nikita Rodin
* :version: 1.0
*/
class AppFeedbackCell: UITableViewCell {
    
    // outlets
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    
    /// segment switch event handler
    var onSwitch: ((Int) -> Void)?
    
    override func awakeFromNib() {
        lowLabel.text = "APP_FEED_LOW_VALUE".localized
        highLabel.text = "APP_FEED_HIGH_VALUE".localized
        segmentControl.addTarget(self, action: "switchHandler", forControlEvents: .ValueChanged)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!, NSForegroundColorAttributeName: segmentControl.tintColor], forState: .Normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Selected)
    }
    
    /**
    switch event handler
    */
    func switchHandler() {
        self.onSwitch?(segmentControl.selectedSegmentIndex)
    }
}

/**
* App feedback text cell
*
* @author Alexander Volkov
* @version 1.0
*/
class AppFeedbackTextCell: UITableViewCell, UITextViewDelegate {
    
    // outlets
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    /// text changed event handler
    var onTextChanged: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
    
    /**
    Move the content up when starts editing
    */
    func textViewDidBeginEditing(textView: UITextView) {
        let offset = self.tableView!.contentSize.height - UIScreen.mainScreen().bounds.height + keyboardHeight
        self.tableView!.contentOffset.y = offset
    }
    
    /**
    Notify about changed text
    */
    func textViewDidEndEditing(textView: UITextView) {
        onTextChanged?(textView.text)
    }
    
    /**
    Dismiss the keyboard when Enter is tapped
    */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        else {
            let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
            onTextChanged?(newText)
            return newText.characters.count <= Configuration.sharedConfig.maxFeedbackLength
        }
        return true
    }
}

/**
* Custom data source for AppFeepbackViewController
*
* @author Alexander Volkov
* @version 1.0
*/
class AppFeedbackDataSource<ItemType, CellType: UIView> : ArrayDataSource<ItemType, CellType> {
    
    /// reference to the view controller
    var viewController: AppFeedbackViewController?
    
    override init() {super.init()}
    
    /**
    Creates new instance.
    
    - parameter items:               The items
    - parameter cellReuseIdentifier: The cell reuse identifier
    - parameter staticTopCells:      The static top cells
    - parameter configureClosure:    The configure closure
    
    - returns: the created instance.
    */
    convenience init(items: [ItemType], cellReuseIdentifier: String, staticTopCells: [UIView] = [],
        configureClosure: ConfigureCellClosure) {
            self.init()
            configure([items], cellReuseIdentifier: cellReuseIdentifier, staticTopCells: [staticTopCells],
                configureClosure: configureClosure)
    }

    /**
    Overrides to instantiate AppFeedbackTextCell for the last cell
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: a configured cell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let n = self.allItems[0].count
        if indexPath.row == n - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("AppFeedbackTextCell",
                forIndexPath: indexPath) as! AppFeedbackTextCell
            cell.numberLabel.text = "\(indexPath.row+1)."
            let item = self.itemAtIndexPath(indexPath) as! AppFeedbackEntry
            cell.titleLabel.text = item.title
            cell.textView.text = item.comment ?? ""
            cell.textView.layer.borderWidth = 1
            cell.textView.layer.borderColor = UIColor.grayColor().CGColor
            cell.onTextChanged = { (text: String)->() in
                self.viewController?.items[indexPath.row].comment = text
                
                if let parent = self.viewController {
                    parent.submitButton.enabled = parent.validateWithAlert(false)
                }
            }
            return cell
        }
        else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
}