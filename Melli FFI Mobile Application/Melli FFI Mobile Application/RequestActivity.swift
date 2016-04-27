//
//  RequestActivity.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the request activity class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - parser added
*/

struct RequestActivityFormatters {
    static var dateParser: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.timeZone = NSTimeZone(name: "UTC")
        return f
        }()
    static var dateStringLength = 19
}

public class RequestActivity : NSObject {

    /// Represents the date.
    var date : NSDate = NSDate()
    /// Represents the name.
    var name : String
    /// Represents the text.
    var text : String
    /// Represents the title.
    var title : String?
    /// Represents the attachment names
    var attachedNames : [String] = []
    
    /**
    Creates new instance.

    - parameter text: The text

    - returns: the created instance.
    */
    init(text: String) {
        self.text = text
        name = AuthenticationUtil.getUserInfo()?.getFullName() ?? ""
    }

    /**
    * Instantiate the instance using the passed dictionary values to set the properties values
    */
    init(fromDictionary dictionary: NSDictionary){
        date = dictionary["date"] as! NSDate
        name = dictionary["name"] as! String
        text = dictionary["text"] as! String
        title = dictionary["title"] as? String
        attachedNames = dictionary["attachedName"] as! [String]
    }
    
    /**
    Parse given JSON data
    
    - parameter json: JSON data
    
    - returns: RequestActivity instance
    */
    class func fromJSON(json: JSON) -> RequestActivity {
        let activity = RequestActivity(text: json["WorkInfoNotes"].stringValue)
        
        var dateString = json["WorkInfoSubmitDate"].stringValue
        dateString = dateString.substringToIndex(dateString.startIndex.advancedBy(RequestActivityFormatters.dateStringLength))
        if let date = RequestActivityFormatters.dateParser.dateFromString(dateString) {
            activity.date = date
        }
        // The author of the activity
        if let name = json["WorkInfoSubmitter"].string {
            activity.name = name == "" ? "<noname>" : name
        }
        /*
        If the user who created the incident is not the same as the user who is currently logged into the
        mobile app, then add “(Support Engineer)”, otherwise this will be blank
        */
        /*
        if activity.name != AuthenticationUtil.getUserInfo()?.getFullName() {
            activity.title = "Support_Engineer".localized
        }
        */
        
        // The attachment names 
        if let array = json["AttachmentNames"].array   {
            for i in 0..<array.count   {
                if let string = array[i].string {
                    activity.attachedNames.append(string)
                }
            }
        }
        
        return activity
    }
}

public class RequestAttachActivity : NSObject {
    
    /// Represents the date.
    var date : NSDate = NSDate()
    /// Represents the name.
    var name : String
    /// Represents the text.
    var text : String
    /// Represents the title.
    var title : String?
    /// Represents the attachment names
    var attachedNames : [String] = []
    /// Represents the workinfo id
    var workinfoId : String?
    
    /**
     Creates new instance.
     
     - parameter text: The text
     
     - returns: the created instance.
     */
    init(text: String) {
        self.text = text
        name = AuthenticationUtil.getUserInfo()?.getFullName() ?? ""
    }
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: NSDictionary){
        date = dictionary["date"] as! NSDate
        name = dictionary["name"] as! String
        text = dictionary["text"] as! String
        title = dictionary["title"] as? String
        attachedNames = dictionary["attachedName"] as! [String]
        workinfoId = dictionary["workinfoId"] as? String
    }
    
    /**
     Parse given JSON data
     
     - parameter json: JSON data
     
     - returns: RequestActivity instance
     */
    class func fromJSON(json: JSON) -> RequestAttachActivity {
        let activity = RequestAttachActivity(text: json["WorkInfoNotes"].stringValue)
        
        var dateString = json["WorkInfoSubmitDate"].stringValue
        dateString = dateString.substringToIndex(dateString.startIndex.advancedBy(RequestActivityFormatters.dateStringLength))
        if let date = RequestActivityFormatters.dateParser.dateFromString(dateString) {
            activity.date = date
        }
        // The author of the activity
        if let name = json["WorkInfoSubmitter"].string {
            activity.name = name == "" ? "<noname>" : name
        }
        // The work inof id of the activity
        if let workinfoid = json["WorkInfoID"].string  {
            activity.workinfoId = workinfoid == "" ? "<noid>" : workinfoid
        }
        /*
        If the user who created the incident is not the same as the user who is currently logged into the
        mobile app, then add “(Support Engineer)”, otherwise this will be blank
        */
        /*
        if activity.name != AuthenticationUtil.getUserInfo()?.getFullName() {
        activity.title = "Support_Engineer".localized
        }
        */
        
        // The attachment names
        if let array = json["AttachmentNames"].array   {
            for i in 0..<array.count   {
                if let string = array[i].string {
                    activity.attachedNames.append(string)
                }
            }
        }
        
        return activity
    }
}