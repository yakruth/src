//
//  Assets.swift
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 2/18/16.
//  Copyright © 2016 Topcoder. All rights reserved.
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
public class Assets : NSObject {
    
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
                return (action: "reopen".localized, status : .Assigned, color: redColor)
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
    
    /// Represents the asset instance id
    var assetInstanceID : String = ""
    /// Represents the asset id
    var assetID : String = ""
    /// Represents the ci name
    var ciName : String = ""
    /// Represents the item
    var item : String = ""
    /// Represents the product name
    var productName : String = ""
    /// Represents the version number
    var versionNumber : String = ""
    /// Represents the manufacturer name 
    var manufacturerName : String = ""
    /// Represents the operating system
    var operatingSystem : String = ""
    /// Represents the end of lease
    var endOfLeaseDate = NSDate()
    /// Represents the person id
    var personID : String = ""
    /// Represents the fault code
    var faultCode : String = ""
    /// Represents the fault string
    var faultString : String = ""
    /// the status
    public var status : Status = .Pending

    
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
    class func fromJSON(json: JSON) -> Assets {
        let assets = Assets()
        assets.assetInstanceID = json["AssetInstanceID"].stringValue
        assets.assetID = json["AssetID"].stringValue
        assets.ciName = json["CIName"].stringValue
        assets.item = json["Item"].stringValue
        assets.productName = json["ProductName"].stringValue
        assets.versionNumber = json["VersionNumber"].stringValue
        assets.manufacturerName = json["ManufacturerName"].stringValue
        assets.operatingSystem = json["OperatingSystem"].stringValue
        
        // ReportedDate
        var dateString = json["EndOfLeaseDate"].stringValue
        dateString = dateString.substringToIndex(dateString.startIndex.advancedBy(RequestActivityFormatters.dateStringLength))
        if let date = RequestActivityFormatters.dateParser.dateFromString(dateString) {
            assets.endOfLeaseDate = date
        }
        
        assets.personID = json["PersonID"].stringValue
        assets.faultCode = json["faultcode"].stringValue
        assets.faultString = json["faultstring"].stringValue
        
        return assets
    }
}
