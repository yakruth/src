//
//  AppDelegate.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/12/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the application delegate class.

@author mohamede1945, Alexander Volkov
@version 1.2
*
* changes:
* 1.1:
* - token validation added
* - Google Analytics support
* 1.2:
* - Survey screen logic changes (screen opening removed)
*/
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Represents the application window.
    var window: UIWindow?

    /**
    Application did finish launching.

    - parameter application:   The application
    - parameter launchOptions: The launch options

    - returns: always true.
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarStyle = .LightContent
        window?.tintColor = UIColor.identity()
        UIScrollView.appearance().keyboardDismissMode = .OnDrag
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.identity()
        UINavigationBar.appearance().barStyle = .Black

        // Log all API requests
        LoggerListener.sharedInstance.start()
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20
        
        // Optional: set Logger to VERBOSE for debug information.
        // CHANGE TO .Verbose FOR DEMONSTRATION OF GOOGLE ANALYTICS WORK. Must be None on production.
        GAI.sharedInstance().logger.logLevel = GAILogLevel.None
        
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId(Configuration.sharedConfig.GoogleAnalyticsAppId)
        
        // Initialize VoiceRecognizer
        //VoiceRecogniser.sharedInstance().initOpenEars()
        
        return true
    }
    
    /**
    Checks token when application is activated. If token is not valid, then need to open Login screen.
    
    - parameter application: the application
    */
    func applicationDidBecomeActive(application: UIApplication) {
        // Reset cache update the app is relaunched
        ServerApi.sharedInstance.cachedIncidentRequests = nil
        ServerApi.sharedInstance.cachedNewsItems = nil
        
        AuthenticationUtil.tryValidateToken({ () -> () in
            // do nothing
        }, noValidToken: { () -> () in
            
            // If token is not valid and the app is not on Login screen, then need to open Login screen
            MenuViewControllerSingleton?.logoutUI()
        })
        
//         Added demonstrate getCurrentCountryCode method. UNCOMMENT to verify. You can also verify it using unit tests.
//        CountryUtil.sharedInstance.getCurrentCountryCode { (code: String) -> () in
//            println("Country code: \(code)")
//        }
    }
    
}

