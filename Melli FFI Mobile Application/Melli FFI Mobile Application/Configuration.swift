//
//  Configuration.swift
//  Meli FFI Mobile Application
//
//  Created by Alexander Volkov on 07.06.15.
//  Updated by Nikita Rodin on 05/08/15
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation


/**
* Configuration reads config from configuration.plist in the app bundle
*
* @author Alexander Volkov
* @version 1.1
*
* changes:
* 1.1:
* - new options added and some are removed
*/
class Configuration: NSObject {
    
    /// Base URL for API. Has default value.
    var apiBaseUrl = "http://localhost:8888/API/"
        
    /// the log level of the Logger. Default value 1 (INFO)
    var loggingLevel: NSInteger = 1
    
    /// parameter for "Create Incident" request
    var reportedSource: String = ""
    
    /*
    Endpoint to emulate and show error for.
    Possible values:
    - UserGetDetail;
    - incidentGetList;
    - incidentGetWorkInfo;
    - IncidentCreate.
    */
    var SHOW_ERROR_FOR_ENDPOINT: String = ""
    
    /// URL of OAuth server
    var OAuthBaseUrl: String = ""
    
    /// Alphanumeric string provided after registration of the Meli App
    var OAuthClientId: String = ""
    
    /// Passphrase provided post registration of client id
    var OAuthClientSecret: String = ""
    
    /// ID that uniquely identifies all Meli applications running on the device
    var OAuthDeviceId: String = ""
    
    /// Google Analytics Appilcation Id
    var GoogleAnalyticsAppId: String = ""
    
    /// Phone number for support
    var callSupportNumber: String = ""
    
    /// max feedback length
    var maxFeedbackLength: Int = 200
    
    /// the probablity to show a Survey screen in percents (0-100)
    var feedbackProbability: Int = 10
    
    /// Represents the requested for search count
    var empSearchCount: Int = 50
    
    /// shared instance of Configuration (singleton)
    class var sharedConfig: Configuration {
        struct Static {
            static let instance : Configuration = Configuration()
        }
        return Static.instance
    }
    
    /**
    Reads configuration file
    */
    override init() {
        super.init()
        self.readConfigs()
    }
    
    // MARK: private methods
    
    /**
    * read configs from plist
    */
    func readConfigs() {
        if let path = getConfigurationResourcePath() {
            let configDicts = NSDictionary(contentsOfFile: path)
            
            if let url = configDicts?["apiBaseUrl"] as? String {
                var clearUrl = url.trim()
                if !clearUrl.isEmpty {
                    if clearUrl.hasPrefix("http") {
                        // Fix "/" at the end if needed
                        if !clearUrl.hasSuffix("/") {
                            clearUrl += "/"
                        }
                        self.apiBaseUrl = clearUrl
                    }
                }
            }
            if let level = configDicts?["loggingLevel"] as? NSNumber {
                self.loggingLevel = level.integerValue
            }
            if let reportedSource = configDicts?["ReportedSource"] as? String {
                self.reportedSource = reportedSource
            }
            if let endpoint = configDicts?["SHOW_ERROR_FOR_ENDPOINT"] as? String {
                self.SHOW_ERROR_FOR_ENDPOINT = endpoint
            }
            
            // OAuth
            if let OAuthBaseUrl = configDicts?["OAuthBaseUrl"] as? String {
                self.OAuthBaseUrl = OAuthBaseUrl
            }
            if let OAuthClientId = configDicts?["OAuthClientId"] as? String {
                self.OAuthClientId = OAuthClientId
            }
            if let OAuthClientSecret = configDicts?["OAuthClientSecret"] as? String {
                self.OAuthClientSecret = OAuthClientSecret
            }
            if let OAuthDeviceId = configDicts?["OAuthDeviceId"] as? String {
                self.OAuthDeviceId = OAuthDeviceId
            }
            if let GoogleAnalyticsAppId = configDicts?["GoogleAnalyticsAppId"] as? String {
                self.GoogleAnalyticsAppId = GoogleAnalyticsAppId
            }
            if let callSupportNumber = configDicts?["callSupportNumber"] as? String {
                self.callSupportNumber = callSupportNumber
            }
            
            // feedback
            self.maxFeedbackLength = configDicts?["maxFeedbackLength"] as? Int ?? self.maxFeedbackLength
            self.feedbackProbability = configDicts?["feedbackProbability"] as? Int ?? self.feedbackProbability
            if self.feedbackProbability < 0 {
                self.feedbackProbability = 0
            }
            else if self.feedbackProbability > 100 {
                self.feedbackProbability = 100
            }
            
            // Added by H146574
            // Requested for Seaarch Results count
            self.empSearchCount = configDicts?["empSearchCount"] as? Int ?? self.empSearchCount
            if self.empSearchCount < 0 {
                self.empSearchCount = 0
            }
            else if self.empSearchCount > 50 {
                self.empSearchCount = 50
            }

            dispatch_async(dispatch_get_main_queue()) {
                let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
                NSUserDefaults.standardUserDefaults().setObject(version, forKey: "buildNumber")
                NSUserDefaults.standardUserDefaults().setObject(Configuration.sharedConfig.apiBaseUrl, forKey: "apiBase")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        else {
            assert(false, "configuration is not found")
        }
    }
    
    /**
    Get the path to the configuration.plist.
    
    - returns: the path to configuration.plist
    */
    func getConfigurationResourcePath() -> String? {
        return NSBundle(forClass: Configuration.classForCoder()).pathForResource("configuration", ofType: "plist")
    }
}