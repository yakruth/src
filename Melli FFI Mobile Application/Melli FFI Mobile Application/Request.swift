//
//  Request.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/16/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the request class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - new statuses
*/
public class Request : NSObject {

    static let orangeColor = UIColor(r: 246, g: 187 , b: 32)
    static let purpleColor = UIColor(r: 150, g: 46 , b: 210)
    static let greenColor = UIColor(r: 111, g: 183 , b: 27)
    static let blueColor = UIColor(r: 74, g: 143, b: 222)
    static let redColor = UIColor(r: 232, g: 52, b: 23)

    /**
    the request status enum.

    - Pending:    The pending
    - InProgress: The in progress
    - Resolved:   The resolved
    - Closed:     The closed
    */
    public enum Status : String {
        case Pending = "pending"
        case InProgress = "in progress"
        case Resolved = "resolved"
        case Closed = "closed"
        case Assigned = "assigned"
        case Unknown = "unknown"
        case Cancelled = "cancelled"
        case New = "new"

        /**
        Gets the color

        - returns: the color.
        */
        func getColor() -> UIColor {
            switch self {
            case .Pending:
                return UIColor.blackColor()
            case .InProgress:
                return UIColor.blackColor()
            case .Resolved:
                return UIColor.blackColor()
            case .Assigned:
                return UIColor.blackColor()
            case .Cancelled:
                return UIColor.blackColor()
            case .Closed:
                return UIColor.blackColor()
            default:
                return UIColor.blackColor()
            }
        }
        
        /**
        Gets the background color that is on the left sid of screen to indicate status of record.
        
        - returns: the color.
        */
        func getBackgroundColor() -> UIColor {
            //return UIColor(r: 228, g: 229, b: 231)
            return UIColor.whiteColor()
        }
        
        
        
        func toString() -> String {
            switch self {
            case .Pending: return "Pending"
            case .InProgress: return "In Progress"
            case .Resolved: return "Resolved"
            case .Closed: return "Closed"
            case .Assigned: return "Assigned"
            case .Unknown: return "Unknown"
            case .Cancelled: return "Cancelled"
            case .New: return "New"
            }
        }

        /**
        Gets next status.

        - returns: the next status.
        */
        func nextStatus() -> (action: String, status: Status, color: UIColor)? {
            switch self {
            case .New, .Assigned, .InProgress, .Pending:
                return (action: "cancel".localized, status : .Cancelled, color: redColor)
            case .Resolved:
                return (action: "reopen", status : .Assigned, color: redColor)
            case .Pending, .Resolved, .Closed, .Cancelled, .Unknown:
                return nil
            }
        }

        var order: Int {
            switch self {
            case .Pending:
                return 1
            case .Resolved:
                return 2
            case .InProgress:
                return 3
            case .Closed:
                return 4
            default:
                return 100
            }
        }
    }

    /**
    The urgency enumeration.
    
    - Low:    The low
    - Medium: The medium
    - High:   The high
    */
    enum Urgency : String {
        case Low  = "4-Low"
        case Medium = "3-Medium"
        case High = "2-High"
        case Critical = "1-Critical"

        /**
        Gets the list of urgencies.

        - returns: the list of urgencies.
        */
        static func urgencies() -> [Urgency] {
            return [.Critical, .High, .Medium, .Low]
        }
    }

    /// Represents the template property.
    var template : TemplateLeaf?
    /// the notes.
    var notes : String = ""
    /// the status
    public var status : Status = .Pending
    /// the summary
    var summary : String = ""
    /// the urgency
    var urgency : Urgency = .Medium
    /// the date
    var date = NSDate()
    /// the attached image name
    var attachedImageName : String = ""
    /// the base 64 string
    var base64String : String = ""
    /// the work info summary
    var workInfoSummary : String = ""
    /// the request id
    var requestId : String = ""
    /// the incident id
    var incidentId : String = ""
    /// the requested for eid
    var requestedEID : String = ""
    /// the asset Name
    var reqAssetName : String = ""
    /// the asset Name
    var assetCI : String = ""
    /// the requested for.
    var requestedBy : String = ""
    /// the requested by.
    var requestedFor : String = ""
    /// the acitivites
    var activities: [RequestActivity] = []
    /// the attachment activities
    var attachActivities: [RequestAttachActivity] = []
    
    /**
    Initialize new instance of the class

    - returns: the created new instance
    */
    override init() {
    }

    /**
    Parse JSON data
    
    - parameter json: JSON data
    
    - returns: Request instance
    */
    class func fromJSON(json: JSON) -> Request {
        let request = Request()
        request.incidentId = json["IncidentId"].stringValue
        request.requestId = json["RequestId"].stringValue
        
        // Status
        var statusStr = json["IncidentStatus"].stringValue
        statusStr = statusStr.lowercaseString   // use lower case
        statusStr = statusStr.replace("-", withString: "")  // removes "-" (for "In-Progress")
        request.status = Status(rawValue: statusStr) ?? Status.Unknown
        
        request.notes = json["IncidentNotes"].stringValue
        request.summary = json["IncidentSummary"].stringValue
        
        // ReportedDate
        var dateString = json["ReportedDate"].stringValue
        dateString = dateString.substringToIndex(dateString.startIndex.advancedBy(RequestActivityFormatters.dateStringLength))
        if let date = RequestActivityFormatters.dateParser.dateFromString(dateString) {
            request.date = date
        }
        
        request.requestedBy = json["ReqByFirstName"].stringValue + " " + json["ReqByLastName"].stringValue
        request.requestedFor = json["ReqForFirstName"].stringValue + " " + json["ReqForLastName"].stringValue

        return request
    }
}

