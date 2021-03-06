//
//  KeychainManager.swift
//  Meli FFI Mobile Application
//
//  Created by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation
import Security

private let kKeychainServiceKey = "kKeychainServiceKey"

/*!
Represents the keychain manager class.

@author Alexander Volkov
@version 1.0
*/
public class KeychainManager {

    /**
    Saves the value

    - parameter key:    the key
    - parameter object: the object

    - returns: true, if sccess.
    */
    public class func save(key: String, object: AnyObject) -> Bool {

        let data = NSKeyedArchiver.archivedDataWithRootObject(object)

        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrService as String : kKeychainServiceKey,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data]

        SecItemDelete(query as CFDictionaryRef)

        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)

        return status == noErr
    }

    /**
    Reads a value

    - parameter key: the key

    - returns: the value read or nil if error
    */
    public class func read(key: String) -> AnyObject? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : kKeychainServiceKey,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne]

        var dataTypeRef :Unmanaged<AnyObject>?

        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0)) }

        //let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)

        if status == noErr {
            if let data = (dataTypeRef!.takeRetainedValue() as? NSData) {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data)
            }
        }
        return nil
    }

    /**
    Deletes a value

    - parameter key: the key

    - returns: true, if sccess
    */
    public class func delete(key: String) -> Bool {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecAttrService as String : kKeychainServiceKey]

        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)

        return status == noErr
    }

    /**
    Removes all the data

    - returns: true, if sccess
    */
    public class func wipe() -> Bool {
        let query = [kSecClass as String : kSecClassGenericPassword]

        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)

        return status == noErr
    }
}
