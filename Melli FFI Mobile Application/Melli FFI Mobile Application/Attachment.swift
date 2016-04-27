//
//  Attachment.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/2/16.
//  Copyright © 2016 Topcoder. All rights reserved.
//

//Added by Manjunath on 02/02/2016
import Foundation

public class Attachment
{
    let workInfoId: String
    let attachmentName: String
    let attachmentData: String
    let faultCode: String
    let faultString: String
    
    init (workInfoId: String, attachmentName: String, attachmentData: String, faultCode: String, faultString: String) {
        self.workInfoId = workInfoId
        self.attachmentName = attachmentName
        self.attachmentData = attachmentData
        self.faultCode = faultCode
        self.faultString = faultString
    }
    
    convenience init(json: JSON) {
        self.init(workInfoId: json["WorkInfoID"].stringValue,
            attachmentName: json["AttachmentName"].stringValue,
            attachmentData: json["AttachmentData"].stringValue,
            faultCode: json["faultcode"].stringValue,
            faultString: json["faultstring"].stringValue)
    }
    
}
//End of Addition