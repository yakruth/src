//
//  LoginViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/13/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import CoreTelephony

/*!
  Represents the login view controller class.
  
  @author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - integration with server API
*/

class LoginViewController: GAITrackedViewController {

    /// Represents the info view.
    @IBOutlet weak var infoView: PagedHorizontalView!
    /// Represents the username field.
    @IBOutlet weak var username: NextResponderTextField!
    /// Represents the password.
    @IBOutlet weak var password: NextResponderTextField!
    /// Represents the login button.
    @IBOutlet weak var loginButton: UIButton!
    /// Represents the login label.
    @IBOutlet weak var loginLabel: UILabel!
    /// Represents the login problems label.
    @IBOutlet weak var loginProblemsLabel: UILabel!

    /// Represents the bottom layout.
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    /// Represents the login label bottom.
    @IBOutlet weak var loginLabelBottom: NSLayoutConstraint!
    /// Represents the login label top.
    @IBOutlet weak var loginLabelTop: NSLayoutConstraint!
    /// Represents the login button top.
    @IBOutlet weak var loginButtonTop: NSLayoutConstraint!
    /// Represents the login button bottom.
    @IBOutlet weak var loginButtonBottom: NSLayoutConstraint!

    /// Represents the info data source.
    var infoDataSource: ArrayDataSource<[String: String], InfoCollectionViewCell>!
    /// Represents the keyboard controller.
    var keyboardController = LoginKeyboardController()

    // API
    let authApi = AuthApi()
    var loginView : LoadingView!
    /**
    View did load.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginLabel.text = "portalLogIn".localized
        loginButton.setTitle("loginButton".localized, forState: .Normal)
        loginProblemsLabel.text = "loginProblemsLabel".localized
        username.placeholder = "usernamePlaceholder".localized
        password.placeholder = "passwordPlaceholder".localized

        keyboardController.controller = self

        username.delegate = username
        password.delegate = password

        infoView.collectionView.registerNib(UINib(nibName: "InfoCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "cell")

        let items = BackendService().getLoginHelp()
        infoDataSource = ArrayDataSource(items: items, cellReuseIdentifier: "cell",
            configureClosure: { (cell, entity, _) -> Void in
            cell.configure(entity)
        })
        infoView.collectionView.dataSource = infoDataSource.proxy
        infoView.pageControl.numberOfPages = infoDataSource.allItems[0].count
       
         //tryCheckToken();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.screenName = "Login Screen"  // Google Analytics screen name
        loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        
        tryCheckToken();
    }
    
    /**
    Check if token exists and validate.
    If token is valid, then move to "Home" screen.
    */
    func tryCheckToken() {
        
        AuthenticationUtil.tryValidateToken({ () -> () in
            // Token is valid - moving to "Home" screen]
            
            /*self.loginView.terminate()
            self.moveToHomeScreen()*/
            
            ServerApi.sharedInstance.getUserDetail({ (userDetails: JSON) -> () in
                
                /*self.username.text = ""
                self.password.text = ""
                self.loginButton.enabled = false*/
                self.loginView.terminate()
                self.moveToHomeScreen()
                
                }, errorCallback: { (error: RestError, response: RestResponse?) -> () in
                    self.loginView.terminate()
                    error.showError()
            })
            
            
            
            
            }, noValidToken: { () -> () in
                // Token is valid - moving to "Home" screen]
                self.loginView.terminate()
                
            }) { () -> () in
                // Token is valid - moving to "Home" screen]
                self.loginView.terminate()
        }
        
        
        /*AuthenticationUtil.tryValidateToken({ () -> () in
        
        // Token is valid - moving to "Home" screen]
        //self.loginView.terminate()
        self.moveToHomeScreen()
        
        })*/
    }

    /**
    View will appear.

    :param: animated The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        keyboardController.startObserving()
    }

    /**
    View will disappear.

    :param: animated The animated
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController.stopObserving()
    }

    /**
    View tapped.

    :param: sender The sender
    */
    @IBAction func viewTapped(sender: AnyObject) {
        view.endEditing(true)
    }

    /**
    Text changed.

    :param: sender The sender
    */
    @IBAction func textChanged(sender: AnyObject) {
        loginButton.enabled = !username.text!.trimmedString().isEmpty && !password.text!.trimmedString().isEmpty
    }

    /**
    Login tapped.

    :param: sender The sender
    */
    @IBAction func loginTapped(sender: AnyObject) {

        // dismiss keyboard
        view.endEditing(true)
    
         loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()
        
        authApi.getToken(username: username.text!.trim(), password: password.text!,
            callback: { (userInfo: UserInfo) -> () in
            ServerApi.sharedInstance.getUserDetail({ (userDetails: JSON) -> () in
                
                self.username.text = ""
                self.password.text = ""
                self.loginButton.enabled = false
                self.loginView.terminate()
                self.moveToHomeScreen()
                
            }, errorCallback: { (error: RestError, response: RestResponse?) -> () in
                self.loginView.terminate()
                error.showError()
            })
            
        }) { (error: RestError, res: RestResponse?) -> () in
            self.loginView.terminate()
            UIAlertView(title: "loginError".localized, message: error.getMessage(), delegate: nil,
                cancelButtonTitle: "ok".localized).show()
        }
    }
    
    /**
    Move to "Home" screen
    */
    internal func moveToHomeScreen() {
        let menu = self.storyboard?.instantiateViewControllerWithIdentifier("menu") as! MenuViewController
        let defaultController = menu.createDefaultContentController()
        let slideController = SlideMenuViewController(sideController: menu, defaultContent: defaultController,
            widthDelegate: menu)
        
        slideController.modalTransitionStyle = .FlipHorizontal
        self.presentViewController(slideController, animated: true, completion: nil)
    }
    
    /**
    "Call support" button action
    
    :param: sender the button
    */
    @IBAction func callAction(sender: AnyObject) {
        if let url = NSURL(string: "tel://" + Configuration.sharedConfig.callSupportNumber) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                if simAvailability()    {
                    UIApplication.sharedApplication().openURL(url)
                }
                else    {
                    UIAlertView(title: "nosimcard".localized, message: nil, delegate: nil,
                        cancelButtonTitle: "ok".localized).show()
                }
                return
            }
        }
        print("Cannot call: \(Configuration.sharedConfig.callSupportNumber)")
    }
    
    /** 
    //Added by H146574
    SIM Detection 
     
    :return value : yes/no
    */
    func simAvailability() -> Bool   {
        if let cellularProvider  = CTTelephonyNetworkInfo().subscriberCellularProvider {
            if let mnCode = cellularProvider.mobileNetworkCode {
                print (mnCode)
                return true
            }
        }
        return false
    }
}
