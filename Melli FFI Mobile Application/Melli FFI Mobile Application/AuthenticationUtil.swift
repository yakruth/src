//
//  AuthenticationUtil.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/// Keys for storing UserInfo details
// flag: is used authenticated or not
let kAuthFlag = "kAuthFlag"
// user id
let kAuthUserName = "kAuthUserName"
// access token to request data on the server
let kAuthAccessToken = "kAuthAccessToken"
// refresh token to update access token
let kAuthRefreshToken = "kAuthRefreshToken"


/// Last used UserInfo instance
var LastUserInfo: UserInfo?

/**
* Utility that provides UserInfo object
*
* @author Alexander Volkov
* @version 1.0
*/
public class AuthenticationUtil {
    
    /**
    Sets "User is authenticated" flag to true and saves UserInfo
    
    - parameter userInfo: info (not used for now)
    */
    public class func setAuthenticated(userInfo: UserInfo) {
        setNotAuthenticated()
        
        LastUserInfo = userInfo
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: kAuthFlag)
        NSUserDefaults.standardUserDefaults().setObject(userInfo.username, forKey: kAuthUserName)
        TokenStorage.saveToken(userInfo.accessToken, key: kAuthAccessToken)
        TokenStorage.saveToken(userInfo.refreshToken, key: kAuthRefreshToken)
        userInfo.save(NSUserDefaults.standardUserDefaults())
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    Sets "User is authenticated" flag to false and clean up UserInfo
    */
    public class func setNotAuthenticated() {
        LastUserInfo = nil
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: kAuthFlag)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kAuthUserName)
        TokenStorage.delete(kAuthAccessToken)
        TokenStorage.delete(kAuthRefreshToken)
        UserInfo.delete(NSUserDefaults.standardUserDefaults())
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    Checks if user is authenticated
    
    - returns: true - if user is authenticated, false - if not
    */
    public class func isAuthenticated() -> Bool {
        if let flag = NSUserDefaults.standardUserDefaults().objectForKey(kAuthFlag) as? Bool {
            return flag
        }
        return false
    }
    
    /**
    Get current access token
    
    - returns: the access token
    */
    class func getCurrentAccessToken() -> String {
        if let token = AuthenticationUtil.getUserInfo()?.accessToken {
            return token
        }
        return ""
    }
    
    /**
    Get current UserInfo
    
    - returns: UserInfo or nil if the user is not authenticated
    */
    class func getUserInfo() -> UserInfo? {
        // Reuse in-memory object if not nil
        if let info = LastUserInfo {
            return info
        }
            
        // Read from the user settings
        else if isAuthenticated() {
            var username: String!
            
            if let name = NSUserDefaults.standardUserDefaults().objectForKey(kAuthUserName) as? String {
                username = name
            }
            let info = UserInfo(username: username)
            
            // Restore tokens from secure storage
            info.accessToken = TokenStorage.getToken(kAuthAccessToken)
            info.refreshToken = TokenStorage.getToken(kAuthRefreshToken)

            info.read(NSUserDefaults.standardUserDefaults())

            return info
        }
        return nil
    }
}

/**
* Shortcut methods
*
* @author Alexander Volkov
* @version 1.0
*/
extension AuthenticationUtil {
    
    /**
    Clean all local data and invokes 'logout' API endpoint.
    
    - parameter callback: the block in invoke after all
    */
    class func logout(callback: ()->()) {
        AuthApi.sharedInstance.logout({ (json: JSON) -> () in
            callback()
        }, errorCallback: { (error: RestError, res:RestResponse?) -> () in
            print("Logout ERROR: \(error.getMessage())")
            callback()
        })
    }
    
    /**
    Check if token exists and validate.
    If token is valid, then move to "Home" screen.
    
    - parameter validTokenCallback: callback to invoke when token is valid
    - parameter noValidToken:       callback to invoke when token is not valid
    - parameter noToken:            callback to invoke when there is no token
    */
    class func tryValidateToken(validTokenCallback: ()->(), noValidToken: (()->())? = nil, noToken: (()->())? = nil) {
        if let token = AuthenticationUtil.getUserInfo()?.accessToken {
            AuthApi.sharedInstance.validateToken(token, callback: { (json: JSON) -> () in
                validTokenCallback()
            }, errorCallback: { (error: RestError, res: RestResponse?) -> () in
                print("Access Token is not valid. Leave Login screen opened.")
                AuthenticationUtil.logout({})
                noValidToken?()
            })
        }
        else {
            noToken?()
        }
    }
}