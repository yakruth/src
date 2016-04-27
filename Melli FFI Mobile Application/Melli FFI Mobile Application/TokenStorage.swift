//
//  TokenStorage.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Utility for saving and restoring tokens.
*
* @author Alexander Volkov
* @version 1.0
*/
public class TokenStorage {
    
    /// key for an access token
    public static let kAccessToken = "kAccessToken"

    /// key for an refresh token
    public static let kRefreshToken = "kRefreshToken"
    
    /**
    Encrypted token.
    
    - parameter key:       the key
    - parameter iv:        the iv
    - parameter encrypted: the encrypted
    */
    typealias EncryptedToken = (key: NSData, iv: NSData, encrypted: String)
    
    /**
    Save token by key
    
    - parameter token: the token
    - parameter key:   the key
    */
    public class  func saveToken(token: String, key: String) {
        let encryptedToken = encryptToken(token)
        let dic = [
            "key" : encryptedToken.key,
            "iv" : encryptedToken.iv,
            "encrypted" : encryptedToken.encrypted,
            "creationDate" : NSDate()
        ]
        // save
        KeychainManager.delete(key)
        KeychainManager.save(key, object: dic)
    }
    
    /**
    Get token by given key.
    
    - parameter key: The key. Use TokenStorage.kAccessToken or TokenStorage.kRefreshToken.
    
    - returns: token
    */
    public class  func getToken(key: String) -> String {
        let existingToken = KeychainManager.read(key) as! [String: AnyObject]
        let token = CryptoManager.decrypt(existingToken["encrypted"] as! String,
            key: existingToken["key"] as! NSData,
            iv: existingToken["iv"] as! NSData)
        return token
    }
    
    /**
    Delete data by given key
    
    - parameter key: the key
    */
    public class func delete(key: String) {
        KeychainManager.delete(key)
    }
    
    /**
    Encrypt the token
    
    - parameter token: the token
    
    - returns: the encrypted token
    */
    class func encryptToken(token: String) -> EncryptedToken {
        
        // Generate random key based on client_id and device_id
        let salt = Configuration.sharedConfig.OAuthClientId + Configuration.sharedConfig.OAuthDeviceId
        let key = CryptoManager.randomBytes(salt, length: kCCKeySizeAES256)
        let iv = CryptoManager.randomBytes(kCCBlockSizeAES128)
        
        let encrypted = CryptoManager.encrypt(token, key: key, iv: iv)
        
        return (key: key, iv: iv, encrypted: encrypted)
    }

}