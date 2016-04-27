//
//  CryptoManager.swift
//  Meli FFI Mobile Application
//
//  Created by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/**
Represents the crypto manager class.

@author Alexander Volkov
@version 1.0
*/
class CryptoManager {
    
    /**
    Hash the parameter with md5 algorithm.

    - parameter data: The data

    - returns: the hashed string.
    */
    class func md5(data: NSData) -> String {
        let strLen = CUnsignedInt(data.length)
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let digest = UnsafeMutablePointer<UInt8>.alloc(digestLen)

        // call the MD5 algorithm
        CC_MD5(data.bytes, strLen, digest)

        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", digest[i])
        }
        digest.dealloc(digestLen)
        digest.destroy()

        return String(hash)
    }

    /**
    Encrypt the message with key and IV

    - parameter message: the message
    - parameter key:     the key
    - parameter iv:      the iv

    - returns: the encrypted message.
    */
    class func encrypt(message: String, key: NSData, iv: NSData) -> String {
        let dataBytes         = message.cStringUsingEncoding(NSUTF8StringEncoding)!
        let dataLength        = message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let cryptData         = NSMutableData(length: dataLength + kCCBlockSizeAES128)!
        let cryptPointer      = UnsafeMutablePointer<UInt8>(cryptData.mutableBytes)
        let cryptLength       = cryptData.length
        var numBytesEncrypted = 0

        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            key.bytes, kCCKeySizeAES256,
            iv.bytes,
            dataBytes, dataLength,
            cryptPointer, cryptLength,
            &numBytesEncrypted)

        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            cryptData.length = numBytesEncrypted
            // Encode to Base64
            let base64cryptString = cryptData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            return base64cryptString
        } else {
            assertionFailure("Error in Encryption '\(cryptStatus)'")
            return ""
        }
    }

    /**
    Decrypt the message

    - parameter message: the message
    - parameter key:     the key
    - parameter iv:      the iv

    - returns: a decrypted message
    */
    class func decrypt(message: String, key: NSData, iv: NSData) -> String {
        let data              = NSData(base64EncodedString: message, options: [])!
        let dataBytes         = UnsafePointer<UInt8>(data.bytes)
        let cryptData         = NSMutableData(length: data.length + kCCBlockSizeAES128)!
        let cryptPointer      = UnsafeMutablePointer<UInt8>(cryptData.mutableBytes)
        let cryptLength       = cryptData.length
        var numBytesEncrypted = 0

        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            key.bytes, kCCKeySizeAES256,
            iv.bytes,
            dataBytes, data.length,
            cryptPointer, cryptLength,
            &numBytesEncrypted)

        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            cryptData.length = numBytesEncrypted
            let string = NSString(data: cryptData, encoding: NSUTF8StringEncoding) as! String
            return string
        } else {
            print("Error in Decryption '\(cryptStatus)'")
            return ""
        }
    }

    /**
    Generates a ranom bytes

    - parameter length: the length

    - returns: random bytes
    */
    class func randomBytes(length: Int) -> NSData {
        let data = NSMutableData(length: Int(length))!
        let result = SecRandomCopyBytes(kSecRandomDefault, length, UnsafeMutablePointer<UInt8>(data.mutableBytes))
        assert(result == 0, "Error generating random number")
        return data
    }
    
    /**
    Generates a ranom bytes using given salt
    
    - parameter salt:   the salt
    - parameter length: the length to generate
    
    - returns: random bytes
    */
    class func randomBytes(salt: String, length:  Int) -> NSData {
        let saltPartLength = length / 2
        let md5 = salt.md5
        let saltData: NSData! = (salt as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let completeData: NSMutableData = saltData.mutableCopy() as! NSMutableData
        completeData.length = saltPartLength
        
        let randomPartLength = length - saltPartLength
        let randomData = CryptoManager.randomBytes(randomPartLength)
        
        completeData.appendData(randomData)
        completeData.length = length
        
        return completeData
    }
}