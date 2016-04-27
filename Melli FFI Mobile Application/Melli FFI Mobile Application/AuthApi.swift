//
//  AuthApi.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Authentication API
*
* @author Alexander Volkov
* @version 1.0
*/
public class AuthApi {
    
    /// instance of raw RestAPI service
    internal let api: RestAPI
    
    /// Information about the device accessing the service. Substituted into the header
    var devicemetadata = "iPhone" + UIDevice.currentDevice().systemVersion
    
    /// the type of the token
    let tokenType = "Bearer"
    
    /// singleton shared instance
    class var sharedInstance: AuthApi {
        struct Singleton { static let instance = AuthApi() }
        return Singleton.instance
    }
    
    /**
    Instantiates AuthApi without access token
    
    - returns: new instance of the endpoint group wrapper
    */
    public init() {
        self.api = RestAPI(baseUrl: Configuration.sharedConfig.OAuthBaseUrl, accessToken: "")
    }
    
    /**
    Authenticate and get Access Token

    - parameter username:      email, username or other identification of the account
    - parameter password:      the password
    - parameter callback:      callback block used to indicate a success and return token
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    public func getToken(username username: String, password: String,
        callback: (UserInfo)->(), errorCallback: (RestError, RestResponse?)->()) {
            // Validate parameters
            if !ValidationUtils.validateStringNotEmpty(username, errorCallback) { return }
            if !ValidationUtils.validateStringNotEmpty(password, errorCallback) { return }
            
            let request = createRequest(.POST, "oauth2")
            
            // If "client_id" is a header, then "client_secret" must be header to
            request.headers?["devicemetadata"] = UIDevice.currentDevice().model

            /*

            "username": username,
            "password": password,
            "grant_type": "password",
            "scope": "read",
            "client_secret":"remedy-89df23-fdhj34-98dsf-dshf3-sd234-key",
            "client_id":"7e6406a0-0b4d-11e5-926f-000c29165c58",
            "deviceID":"123214"
            */
            
            request.parameters = [
                "username": username,
                "password": password,
                "grant_type": "password",
                "scope": "read",
                "client_secret":Configuration.sharedConfig.OAuthClientSecret,
                "client_id": Configuration.sharedConfig.OAuthClientId,
                "deviceID":Configuration.sharedConfig.OAuthDeviceId
            ]
            
            // Send request
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: {
                (json: JSON, response: RestResponse?) -> () in
                let info = UserInfo(username: username)
                info.accessToken = json["access_token"].stringValue
                info.refreshToken = json["refresh_token"].stringValue
                AuthenticationUtil.setAuthenticated(info)   // Save authorization info for further usage
                callback(info)
                }, errorCallback: errorCallback)
            
            
    }
    
/*
    func getToken(#username: String, password: String,
        callback: (UserInfo)->(), errorCallback: (RestError, RestResponse?)->()) {
            
            // Validate parameters
            if !ValidationUtils.validateStringNotEmpty(username, errorCallback) { return }
            if !ValidationUtils.validateStringNotEmpty(password, errorCallback) { return }

            let request = createRequest(.POST, "oauth2")
            // If "client_id" is a header, then "client_secret" must be header too
            request.headers?["client_secret"] = Configuration.sharedConfig.OAuthClientSecret
            request.parameters = [
                "username": username,
                "password": password,
                "grant_type": "password",
                "scope": "read"
            ]

            // Send request
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: {
                (json: JSON, response: RestResponse?) -> () in

                let info = UserInfo(username: username)
                info.accessToken = json["access_token"].stringValue
                info.refreshToken = json["refresh_token"].stringValue
                AuthenticationUtil.setAuthenticated(info)   // Save authorization info for further usage
                callback(info)
                
            }, errorCallback: errorCallback)
    }
**/
    /**
    Validate given token
    
    - parameter token:         the token
    - parameter callback:      callback block used to indicate a success
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func validateToken(token: String, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        // Validate parameter
        
        if !ValidationUtils.validateStringNotEmpty(token, errorCallback) { return }
        let request = createRequest(.POST, "validateToken")
            request.headers?["client_id"] = Configuration.sharedConfig.OAuthClientId
            request.headers?["deviceID"] = Configuration.sharedConfig.OAuthDeviceId
            request.headers?["Authorization"] = "\(tokenType) \(token)"
            request.headers?["devicemetadata"] = UIDevice.currentDevice().model
            request.headers?["Encoding"] = "UTF-8"
            request.headers?["Content-Type"] = "application/x-www-form-urlencoded"
        
        // Send request
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json: JSON, response: RestResponse?) -> () in
            callback(json)
            }, errorCallback: errorCallback)
    }
    
    /*
    func validateToken(token: String, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameter
        if !ValidationUtils.validateStringNotEmpty(token, errorCallback) { return }
        
        let request = createRequest(.POST, "validateToken")
        request.headers?["Authorization"] = "\(tokenType) \(token)"
        
        // Send request
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json: JSON, response: RestResponse?) -> () in
            callback(json)
        }, errorCallback: errorCallback)
    }
    */
    /**
    Refresh existing Access Token
    
    - parameter refreshToken:  the refresh token
    - parameter callback:      callback block used to indicate a success and return token
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func refreshToken(refreshToken: String,
        callback: (UserInfo)->(), errorCallback: (RestError, RestResponse?)->()) {
            
            let currentUserInfo: UserInfo! = AuthenticationUtil.getUserInfo()
            
            // Validate parameters
            if !ValidationUtils.validateStringNotEmpty(refreshToken, errorCallback) { return }
            if !ValidationUtils.validateNil(currentUserInfo, errorCallback) { return }
            
            let request = createRequest(.POST, "refresh")
            request.headers?["client_secret"] = Configuration.sharedConfig.OAuthClientSecret
            request.parameters = [
                "refresh_token": refreshToken,
                "grant_type": "refresh_token",
                "scope": "read"
            ]
            
            // Send request
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: {
                (json: JSON, response: RestResponse?) -> () in
                
                currentUserInfo.accessToken = json["access_token"].stringValue
                currentUserInfo.refreshToken = json["refresh_token"].stringValue
                AuthenticationUtil.setAuthenticated(currentUserInfo)   // Update authorization info
                callback(currentUserInfo)
                
            }, errorCallback: errorCallback)
    }
    
    /**
    Get User Profile Information.
    Also updates user info object.
    
    - parameter callback:      callback block used to indicate a success
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func getUserProfile(callback: (UserInfo)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        let currentUserInfo: UserInfo! = AuthenticationUtil.getUserInfo()
        
        // Validate parameters
        if !validateUserInfo(currentUserInfo, errorCallback) { return }
        
        let request = createRequest(.POST, "userprofile")
        request.headers?["Authorization"] = "\(tokenType) \(currentUserInfo.accessToken)"
        
        // Send request
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json: JSON, response: RestResponse?) -> () in

            // Update first and last names only if they are empty.
            if currentUserInfo.firstName.isEmpty {
                if let firstName = json["firstName"].string {
                    currentUserInfo.firstName = firstName
                }
            }
            if currentUserInfo.lastName.isEmpty {
                if let lastName = json["lastName"].string {
                    currentUserInfo.lastName = lastName
                }
            }
            AuthenticationUtil.setAuthenticated(currentUserInfo)   // Update info
            callback(currentUserInfo)
            
        }, errorCallback: errorCallback)
    }
    
    /**
    Logout request
    
    - parameter token:         the token
    - parameter callback:      callback block used to indicate a success and return token
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func logout(callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
            
        let currentUserInfo: UserInfo! = AuthenticationUtil.getUserInfo()
        AuthenticationUtil.setNotAuthenticated() // Clean local data anyway
    
        // Validate parameters
        if !validateUserInfo(currentUserInfo, errorCallback) { return }
        
        let request = createRequest(.POST, "logout")
        request.requestType = .JSON
        request.parameters = [
            "access_token": currentUserInfo.accessToken,
            "username": currentUserInfo.username
        ]
        
        // Send request
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json: JSON, response: RestResponse?) -> () in
            callback(json)
        }, errorCallback: errorCallback)
    }
    
    /**
    Validate local UserInfo
    
    - parameter userInfo:      the userinfo to validate
    - parameter errorCallback: callback block used to notify about validation error
    
    - returns: true if success validation
    */
    internal func validateUserInfo(userInfo: UserInfo?, _ errorCallback: (RestError, RestResponse?)->()) -> Bool {
        if !ValidationUtils.validateNil(userInfo, errorCallback) { return false }
        if !ValidationUtils.validateStringNotEmpty(userInfo!.accessToken, errorCallback) { return false }
        return true
    }
    
    /**
    Create request object
    
    - parameter method:   request method
    - parameter endpoint: the endpoint
    
    - returns: RestRequest instance
    */
    internal func createRequest(method: RestMethod, _ endpoint: String) -> RestRequest {
        let request = RestRequest(method, endpoint)
        
        request.requestType = .FORM
        request.headers = [
            "devicemetadata": self.devicemetadata,
            "client_id": Configuration.sharedConfig.OAuthClientId,
            "deviceID": Configuration.sharedConfig.OAuthDeviceId,
            "Access-Control-Allow-Origin": "*"
        ]
        return request
    }
}