//
//  ServerApi.swift
//  Meli FFI Mobile Application
//
//  Created by Volkov Alexander on 06.06.15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation

/// the error message to show if the credentials are wrong (not found on the server)
let ERROR_CANNOT_AUTHENTICATE = "Cannot sign in with provided credentials"

/**
* Server API implementation
*
* @author Alexander Volkov
* @version 1.1
*
* changes:
* 1.1:
* - new API methods implementation
*/
public class ServerApi {
    
    /// instance of raw RestAPI service
    internal let api: RestAPI
    
    /// EID (the username passed in at login)
    // TODO REMOVE the following line and uncomment the next one.
    //let eid = "E365944"
    let eid = AuthenticationUtil.getUserInfo()?.username ?? ""
    
    // cache for "incidentGetList" request
    var cachedIncidentRequests: [Request]?

    // cache for "incidentGetList" request
    var cachedAssetsRequests: [Assets]?

    // cache for "getNewsAndAlertsParsed" request
    var cachedNewsItems: [NewsAlertItem]?
    
    /// the maximum number of records
    var lastUsedMaxRecords: Int = 0

    /// Represents the cached template tree property.
    var cachedTemplateTree: TemplateRoot?

    /// singleton shared instance
    public class var sharedInstance: ServerApi {
        struct Singleton { static let instance = ServerApi() }
        return Singleton.instance
    }
    
    /**
    Instantiates AuthApi with the given access token
    
    - returns: new instance of the endpoint group wrapper
    */
    internal init() {
        self.api = RestAPI(baseUrl: Configuration.sharedConfig.apiBaseUrl,
            accessToken: "")
    }
    
    // MARK:- API methods
    
    /**
    Get user details
    
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getUserDetail(callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        let currentUserInfo: UserInfo! = AuthenticationUtil.getUserInfo()
        if !ValidationUtils.validateNil(currentUserInfo, errorCallback) { return }
        
        let request = createRequest(.POST, addCommonGetParams("Profile/UserGetDetail"))
        request.parameters = [
            "EID": AuthenticationUtil.getUserInfo()!.username
        ]
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (data, response) -> () in
            
            var json = data
            if let array = json.array {
                if array.count > 0 {
                    json = array[0]
                }
            }
            // Update the UserInfo
            currentUserInfo.read(json)

            AuthenticationUtil.setAuthenticated(currentUserInfo) // Update info
            callback(json)
            
            }, errorCallback: errorCallback)
    }
    
    /**
    Get incidents list data
    
    - parameter status:        The status filter. Default "Assigned,In Progress"
    - parameter maxRecords:    The number of records to request. Default 25.
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getIncidentsList(status: String = "Assigned,In Progress,New,Pending,Resolved,Closed,Cancelled", maxRecords: Int = 25, assetCI: String,
        callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
            let request = createRequest(.POST, addCommonGetParams("Incident/GetList"))
            
            let username = AuthenticationUtil.getUserInfo()?.username ?? ""
            let personId = AuthenticationUtil.getUserInfo()?.personId ?? ""

            request.parameters = [
                "PersonID": personId,
                "EID": username,
                "Status": status,
                "MaxRecords": maxRecords,
                "AssetCI": assetCI
            ]
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                callback(json)
                }, errorCallback: errorCallback)
    }
    
    /**
    Get additional information for given incident.
    
    - parameter incidentNumber: the incident number
    - parameter callback:       the callback block to return success response data
    - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func getWorkInfo(incidentNumber: String, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameter
        if !ValidationUtils.validateStringNotEmpty(incidentNumber, errorCallback) { return }
        
        let request = createRequest(.POST, addCommonGetParams("Incident/GetWorkInfo"))
        
        request.parameters = [
            "IncidentID": incidentNumber
        ]
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            callback(json)
            }, errorCallback: errorCallback)
    }
    
    /**
    Create new request
    
    - parameter requestData:   new request data
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func createRequest(requestData: Request, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {

//        if requestData.template == nil {
//            errorCallback(RestError.errorWithMessage("Template shouldn't be nil"), nil)
//            return
//        }

        let templateId: String
        if let template = requestData.template {
            templateId = template.instanceId
        } else {
            templateId = TemplateLeaf.genericTemplateId()
        }

        let request = createRequest(.POST, addCommonGetParams("Incident/Create"))
        
        let summary = requestData.summary
        let notes = requestData.notes
        
        let attachedImageName = requestData.attachedImageName
        let base64String = requestData.base64String
        let workinfosummary = requestData.workInfoSummary
        let requestedEID = requestData.requestedEID
        let assetci = requestData.assetCI
        
        request.parameters = [
            "UserFirstName": AuthenticationUtil.getUserInfo()!.firstName,
            "UserLastName": AuthenticationUtil.getUserInfo()!.lastName,
            "EID": AuthenticationUtil.getUserInfo()!.username,
            "ReportedSource": Configuration.sharedConfig.reportedSource,
            "Summary": summary,
            "Notes": notes,
            "Urgency": requestData.urgency.rawValue,
            "TemplateID": templateId,
            "AttachmentName": attachedImageName,
            "AttachmentData": base64String,
            "WorkInfoSummary": workinfosummary,
            "RequestedForEID": requestedEID,
            "AssetCI": assetci
        ]
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            // Update ID
            requestData.incidentId = json[0]["Incident_Number"].stringValue
            
            // Save in cache
            self.cachedIncidentRequests?.append(requestData)
            
            // Cut off
            if let list = self.cachedIncidentRequests {
                if list.count > self.lastUsedMaxRecords && self.lastUsedMaxRecords > 0 {
                    self.cachedIncidentRequests!.removeAtIndex(0)
                }
            }
            
            callback(json)
            }, errorCallback: errorCallback)
    }
    
    /**
    Update status of the given Incident Request
    
    - parameter requestData:   the request
    - parameter status:        the status to apply
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func updateStatus(requestData: Request, status: Request.Status,
        callback: (Request)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Incident/UpdateStatus"))

        request.parameters = [
            "IncidentID": requestData.incidentId,
            "Status": status.toString()
        ]
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in

            requestData.status = status
            
            callback(requestData)
        }, errorCallback: errorCallback)
    }

    /**
    Create new Work Info
    
    - parameter requestData:   the request to attach the new work
    - parameter summary:       the work summary
    - parameter notes:         the work notes
    - parameter type:          the work type
    - parameter source:        the work source
    - parameter locked:        the work locked
    - parameter viewAccess:    the work view access
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func createWorkInfo(requestData: Request, summary: String, notes: String,
        type: String, source: String, locked: Bool, viewAccess: String, imageName: String, base64String: String,
        callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
            
            let request = createRequest(.POST, addCommonGetParams("Incident/CreateWorkInfo"))
            
            var summary1 = summary
            if (summary.characters.count > 100) {
                let index1 = summary.startIndex.advancedBy(100)
                summary1 = summary.substringToIndex(index1)
            }
            
            request.parameters = [
                "IncidentID": requestData.incidentId,
                "Summary": summary1,
                "Notes": notes,
                "Type": type,
                "Source": source,
                "Locked": locked ? "Yes" : "No",
                "ViewAccess": viewAccess,
                "Action": "MODIFY",
                "Submitter": AuthenticationUtil.getUserInfo()!.username,
                "AttachmentName": imageName,
                "AttachmentData": base64String
            ]
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                callback(json)
            }, errorCallback: errorCallback)
    }

    /**
    List of templates callback.

    - parameter qualification: The qualification parameter.
    - parameter callback:      The callback parameter.
    */
    public func listOfTemplates(qualification: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {

        let request = createRequest(.POST, addCommonGetParams("Template/GetList"))
        
        request.parameters = [ "qualification" : qualification]

        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in

            callback(json)

        }, errorCallback: errorCallback)
    }
    
    /**
    Submit a feedback
    
    - parameter text:          the feedback text
    - parameter source:        The source of the feedback. Default value "Other"
    - parameter callback:      the callback block to invoke when success
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func feedback(text: String, source: String = "User", callback: () -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameters
        if !ValidationUtils.validateStringNotEmpty(text, errorCallback) { return }
        if !ValidationUtils.validateStringNotEmpty(source, errorCallback) { return }
        
        let request = createRequest(.POST, addCommonGetParams("Feedback/Submit"))
        
        request.parameters = [
            "EID": AuthenticationUtil.getUserInfo()!.username,
            "Comments": text,
            "Source": source
        ]
        
        let alertview: UIAlertView = UIAlertView(title: nil, message: "Thank you for your feedback", delegate: nil, cancelButtonTitle: nil)
        alertview.show()

        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            alertview.dismissWithClickedButtonIndex(-1, animated: true)
            callback()
            
        }, errorCallback: errorCallback)
    }
    
    /**
    Get questions for Survey screen
    
    - parameter callback:      the callback block to return data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getSurveyQuestions(callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Survey/QGetDetail"))
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            callback(json)
            
        }, errorCallback: errorCallback)
    }
    
    
    /**
    Submit Survey screen data

    - parameter incidentNumber: the ID of the related incident request
    - parameter data:           the list of questions and comments from Survey screen
    - parameter source:        The source of the feedback. Default value "Application" as in the challenge example.
    - parameter status:        The status of the feedback. Default value "Responded" as in the challenge example.
    - parameter callback:       the callback block to invoke when success
    - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func submitSurveryData(incidentNumber: String, data: [AppFeedbackEntry],
        source: String = "Application", status: String = "Responded",
        callback: () -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameter
        if !ValidationUtils.validateId(incidentNumber, errorCallback) { return }
        
        let request = createRequest(.POST, addCommonGetParams("Survey/Submit"))
        
        request.parameters = [
            "EID": AuthenticationUtil.getUserInfo()!.username,
            "Incident_Number": incidentNumber,
            "Source": source,
            "Status": status
        ]
        var i = 0
        for item in data {
            if let comment = item.comment {
                request.parameters?["Comments"] = comment
            }
            else {
                i++
                request.parameters?["Question_\(i)"] = item.title
                var value = item.answer ?? 0
                value++
                request.parameters?["Rating\(i)"] = value
            }
        }
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            callback()
            
        }, errorCallback: errorCallback)
    }
    
    /**
    
    */
    /**
    Search in FAQ
    
    - parameter string:        the search string
    - parameter startRecord:   the start record index
    - parameter maxLimit:      the maximum number of returned results
    - parameter callback:      the callback block to return data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func searchFAQ(string: String, startRecord: Int = 0, maxLimit: Int = 30,
        callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
            // Validate parameter
            if !ValidationUtils.validateStringNotEmpty(string, errorCallback) { return }
            
            let request = createRequest(.POST, addCommonGetParams("FAQ/GetList"))
            
            let keywords = string.characters.split {$0 == " "}.map { String($0) }
            var pairs = [String]()
            for keyword in keywords {
                pairs.append("'Article_Keywords' LIKE \"%\(keyword)%\" OR 'ArticleTitle' LIKE \"%\(keyword)%\"")
            }
            var t1 = "- Global -"
            
            let query = "( " + pairs.joinWithSeparator(" OR ")
                + ") AND (('Visibility Assignee Groups' LIKE \"0;%\")  OR ('Visibility Assignee Groups' LIKE \"%;0;%\" ))"
            request.parameters = [
                "Qualification": query,
                "startRecord": 0,
                "maxLimit": 30
            ]
            
            api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                callback(json)
                
            }, errorCallback: errorCallback)
    }
    
    /**
    Get FAQ item details
    
    - parameter item:          the faq item returned from a search
    - parameter callback:      the callback block to return data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func faqDetails(item: FAQItem, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
            // Validate parameter
            if !ValidationUtils.validateNil(item.docId, errorCallback)
            || !ValidationUtils.validateStringNotEmpty(item.docId, errorCallback) { return }
            
            let request = createRequest(.POST, addCommonGetParams("FAQ/GetDetail"))
        
            let query = "'DocID'=\"\(item.docId)\""
            request.parameters = [
                "Qualification": query,
                "startRecord": 0,
                "maxLimit": 1
            ]
            
            api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                callback(json)
                
            }, errorCallback: errorCallback)
    }

    /**
    Get news and alerts
    */
    private func getNewsAndAlerts(sbg: String, eid: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
            let request = createRequest(.POST, addCommonGetParams("Alerts/GetDetails"))
        
            request.parameters = [
                "SBG": sbg,
                "EID": eid
            ]
            
            api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                callback(json)
                
            }, errorCallback: errorCallback)
    }


    /**
    Get a list of possible subscriptions
    
    */
    public func getSubscriptions(eid: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Alerts/GetEnabled"))
        
        request.parameters = [
            "EID": eid
        ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            callback(json)
            
        }, errorCallback: errorCallback)
    }
    
    /**
    Get the list of enabled subscriptions
    
    - parameter eid:           the username used as EID parameter
    - parameter callback:      the callback block to return data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getEnabledSubscriptions(eid: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Alerts/GetSubscribed"))
        
        request.parameters = [
            "EID": eid
        ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            callback(json)
            
        }, errorCallback: errorCallback)
    }

    public func setSubscriptions(eid: String, contentLabel: String, subscriptionFlag: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Alerts/Subscribe"))
        
        request.parameters = [
            "EID": eid,
            "ContentLabel": contentLabel,
            "SubscriptionFlag": subscriptionFlag
        ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            ServerApi.sharedInstance.clearNewsAndAlertsCache()
            callback(json)
            
        }, errorCallback: errorCallback)
    }
    
    
    public func setSubscriptions2(eid: String, contentLabel: String, subscriptionFlag: String,
        callback: () -> (), errorCallback: (RestError, RestResponse?)->()) {
            
            let request = createRequest(.POST, addCommonGetParams("Alerts/Subscribe"))
            
            request.parameters = [
                "EID": eid,
                "ContentLabel": contentLabel,
                "SubscriptionFlag": subscriptionFlag
            ]

            api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                callback()
                
            }, errorCallback: errorCallback)
    }
    
    /**
    Get the phone numbers / emails specific for the user using the phone
    
    - parameter sbg:           a parameter from the user profile
    - parameter sbu:           a parameter from the user profile
    - parameter countryCode:   country code
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getServiceDeskDetails(sbg: String, sbu: String, countryCode: String, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameter
        if !ValidationUtils.validateStringNotEmpty(countryCode, errorCallback) { return }
        if !ValidationUtils.validateStringNotEmpty(sbg, errorCallback) { return }
        //        if !ValidationUtils.validateStringNotEmpty(sbu, errorCallback) { return }
        
        let request = createRequest(.POST, addCommonGetParams("ServiceDesk/GetDetails"))
        
        request.parameters = [
            "SBG": sbg,
            "SBU": sbu,
            "Country": countryCode
        ]
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            callback(json)
            
        }, errorCallback: errorCallback)
    }
    
    // MARK: Private methods
    
    /**
    Create request object
    
    - parameter method:   request method
    - parameter endpoint: the endpoint
    
    - returns: RestRequest instance
    */
    internal func createRequest(method: RestMethod, _ endpoint: String) -> RestRequest {
        let request = RestRequest(method, endpoint)
        request.requestType = .FORM
        request.accessToken = AuthenticationUtil.getCurrentAccessToken()
        let tokenType = "Bearer"
        
        let token = AuthenticationUtil.getUserInfo()?.accessToken ?? ""
        request.headers = [
            "Encoding": "UTF-8",
            "Content-Type":"application/x-www-form-urlencoded",
            "authorization": "\(tokenType) \(token)",
            "devicemetadata": UIDevice.currentDevice().model,
            "client_id": Configuration.sharedConfig.OAuthClientId,
            "deviceID": Configuration.sharedConfig.OAuthDeviceId,
            "Access-Control-Allow-Origin": "*"
            
        ]
        return request
    }
    
    /**
    Add additional GET params to the basepoint.
    Used to emulate error response for a particular request.
    
    - parameter basepoint: the basepoint string
    
    - returns: special GET params as a string or empty string
    */
    internal func addCommonGetParams(basepoint: String) -> String {
        if basepoint == Configuration.sharedConfig.SHOW_ERROR_FOR_ENDPOINT {
            return "\(basepoint)?showError=yes"
        }
        return basepoint
    }
}

/**
* Extends API to provide simplified methods that parse corresponding JSON response and return model objects
*
* @author Alexander Volkov
* @version 1.0
*/
extension ServerApi {
    
    
    /**
    Function clears the cached variables to be reloaded when the app is restarted.
    **/
    public func clearCache() {
        cachedIncidentRequests = nil
        cachedNewsItems = nil
        cachedTemplateTree = nil
        lastUsedMaxRecords = 0
    }
    
    /**
    Clear the cached variabled related to News and Alerts screen and counters.
    */
    public func clearNewsAndAlertsCache() {
        cachedNewsItems = nil
    }
    
    /**
    Get incidents list
    
    - parameter status:        The status filter. Default "Assigned,In Progress"
    - parameter maxRecords:    The number of records to request. Default 25.
    - parameter forseLoad:     flag: true - load from server, false - try reuse cache
    - parameter callback:      the callback block to return a list of incident requests
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func getIncidentsListParsed(status: String = "Assigned,In Progress,New,Pending,Resolved,Closed,Cancelled", maxRecords: Int = 25, assetCI: String, forseLoad: Bool = false,
        callback: ([Request])->(), errorCallback: (RestError, RestResponse?)->()) {
            self.lastUsedMaxRecords = maxRecords
            if !forseLoad {
                if let list = cachedIncidentRequests {
                    callback(list)
                    return
                }
            }
            self.getIncidentsList(status, maxRecords: maxRecords, assetCI: assetCI, callback: { (json: JSON) -> () in
                
                var list = [Request]()
                let data = json
                if let array = data.array {
                    for item in array {
                        list.append(Request.fromJSON(item))
                    }
                }
                // If single item provided
                else if let singleItemId = data["IncidentId"].string {
                    list.append(Request.fromJSON(json))
                }
                
                // Update cache
                self.cachedIncidentRequests = list
                callback(list)
                
            }, errorCallback: errorCallback)
    }
    
    /**
    Caching wrapper for getNewsAndAlerts(). See getNewsAndAlerts() docs.
    */
    public func getNewsAndAlertsParsed(sbg: String, eid: String, forseLoad: Bool = false,
        callback: ([NewsAlertItem]) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
            if !forseLoad {
                if let list = cachedNewsItems {
                    callback(list)
                    return
                }
            }
            
            self.getNewsAndAlerts(sbg, eid: eid, callback: { (json:JSON) -> () in
                var newsItems = [NewsAlertItem]()
                
                for item in json.arrayValue {
                    newsItems.append(NewsAlertItem(json: item))
                }
                newsItems.sortInPlace{ $0.availabilityDate.compare($1.availabilityDate) == NSComparisonResult.OrderedDescending }
                
                // Update cache
                self.cachedNewsItems = newsItems
                callback(newsItems)
                
            }, errorCallback: errorCallback)
    }
    
    /**
    Get additional information for given incident.
    
    - parameter incidentNumber: the incident number
    - parameter callback:       the callback block to return a list of activities
    - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func getWorkInfoParsed(incidentNumber: String,
        callback: ([AnyObject])->(), AttachmentCallback: ([RequestAttachActivity])->(), errorCallback: (RestError, RestResponse?)->()) {
            self.getWorkInfo(incidentNumber, callback: { (json: JSON) -> () in
                
                var list = [AnyObject]()
                //var alist = [RequestAttachActivity]()
                if let array = json.array {
                    for item in array {
                        //list.append(RequestActivity.fromJSON(item))

                        let array = item["AttachmentNames"].array
                        if (array!.count == 0)  {
                            list.append(RequestActivity.fromJSON(item))
                        }
                        else {
                            list.append(RequestAttachActivity.fromJSON(item))
                        }
                    }
                }
                
                callback(list)
                //AttachmentCallback(alist)
            }, errorCallback: errorCallback)
    }
    
    /**
    Create new Work Info
    
    - parameter requestData:   the request to attach the new work
    - parameter summary:       the work summary
    - parameter notes:         the work notes
    - parameter type:          the work type
    - parameter source:        the work source
    - parameter locked:        the work locked
    - parameter viewAccess:    the work view access
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func createWorkInfoParsed(requestData: Request, summary: String, notes: String,
        type: String, source: String, locked: Bool, viewAccess: String, imageName: String, base64String: String,
        callback: (RequestActivity)->(), errorCallback: (RestError, RestResponse?)->()) {
            
            self.createWorkInfo(requestData, summary: summary, notes: notes, type: type, source: source, locked: locked,
                viewAccess: viewAccess, imageName: imageName, base64String: base64String, callback: { (json: JSON) -> () in
                
                let activity = RequestActivity(text: summary)
                // TODO probably we need to add corresponding properties to RequestActivity class
                
                callback(activity)
                
            }, errorCallback: errorCallback)
    }

    /**
    Create new Work Info

    - parameter requestData:   the request to attach the new work
    - parameter text:          the info text
    - parameter callback:      the callback block to return success response data
    - parameter errorCallback: the callback block to return an error and related raw response
    */
    public func createWorkInfo(requestData: Request, text: String, imageName: String, base64String: String,
        callback: (RequestActivity)->(), errorCallback: (RestError, RestResponse?)->()) {

            createWorkInfoParsed(requestData, summary: text, notes: text, type: "General Information", source: "Other",
                locked: false, viewAccess: "Public", imageName: imageName, base64String: base64String, callback: callback, errorCallback: errorCallback)

    }

    /**
    List of templates parsed callback.

    - parameter callback: The callback parameter.
    */
    public func listOfTemplatesParsed(callback callback: (TemplateRoot) -> (), errorCallback: (RestError, RestResponse?)->()) {

        // Always get from the cache, cache expires only when app is foced closed
        if let tree = cachedTemplateTree {
            callback(tree)
            return
        }
        //listOfTemplates("'Status Template' = \"Enabled\"", callback: { (json: JSON) -> () in
        listOfTemplates(BackendService().getDataSource("templateListQualificationValue")as! String, callback: { (json: JSON) -> () in
            func extractTiers(json: JSON) -> [String] {
                var tiers: [String] = []

                for tier in ["COE_HONTier1", "COE_HONTier2", "COE_HONTier3"] {
                    let value = json[tier].stringValue
                    if value.trimmedString().isEmpty {
                        break
                    }
                    tiers.append(value)
                }

                return tiers
            }

            let root = TemplateRoot()

            var intermediate: [String: TemplateNode] = [:]
            var leaves: [TemplateLeaf] = []

            for json in json.arrayValue {

                let tiers = extractTiers(json)
                var parentTemplate: TemplateNode = root

                // expand the branch
                for var i = 0; i < tiers.count; i++ {
                    let tier = tiers[i]

                    // key should contain the level
                    let key = "\(i)#\(tier)"

                    let currentTemplate: TemplateNode
                    // if the node exists and not a leaf, get it
                    if let template = intermediate[key] where i != tiers.count - 1 {
                        currentTemplate = template
                    } else {
                        // node doesn't exist, create it and add it to the tree
                        if i < tiers.count - 1 {
                            currentTemplate = TemplateNode(name: tier)
                        } else {
                            currentTemplate = TemplateLeaf(name: tier, json: json)
                        }
                        parentTemplate.addChildNode(currentTemplate)
                        intermediate[key] = currentTemplate
                    }

                    parentTemplate = currentTemplate
                }
            }

            // update the cache
            self.cachedTemplateTree = root
            
            //Added by Manjunath on 26/10/2015
            if self.cachedTemplateTree != nil   {
                let currentTemplate: TemplateNode
                currentTemplate = TemplateNode(name: "AAAFavorites")

                self.cachedTemplateTree?.addChildNode(currentTemplate)
            }
            //End of Addition
            
            // result available
            callback(root)

        }, errorCallback: errorCallback)

    }
    
    
    //Added by Manjunath on 20/10/2015
    /**
    Create new Favorite
    
    - parameter EID:
    - parameter TemplateName:
    - parameter HPD_Template_ID:
    - parameter Favorite:
    */
    public func createFavorite(templateleaf: TemplateLeaf, favoriteItem: String,
        callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
            
            let request = createRequest(.POST, addCommonGetParams("Template/CreateFavorite"))
            
            request.parameters = [
                "EID": AuthenticationUtil.getUserInfo()!.username,
                "TemplateName": templateleaf.templateName,
                "HPD_Template_ID": templateleaf.templateId,
                "Favorite": favoriteItem
            ]
            
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                callback(json)
            }, errorCallback: errorCallback)
    }
    //End of Addition

    //Added by Manjunath on 20/10/2015
    /**
    Get All Favorites
    
    - parameter EID:
    */
    public func getFavorite(callback: ([String: TemplateNode]) -> (), errorCallback: (RestError, RestResponse?)->()) {
            
            let request = createRequest(.POST, addCommonGetParams("Template/GetFavorites"))
            
            request.parameters = [
                "EID": AuthenticationUtil.getUserInfo()!.username,
            ]
            
            self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
                
                var allfavorites = Dictionary<String, TemplateNode>()
                
                for json in json.arrayValue {
                    //var template = Favorites(json: json)
                    let templateName = json["TemplateName"].stringValue
                    let template = TemplateLeaf(name: templateName, json: json)
                    let templateNode = template as TemplateNode
                    allfavorites[template.templateId] = templateNode
                }
                
                
                callback(allfavorites)
                
            }, errorCallback: errorCallback)
    }
    //End of Addition

    //Added by Manjunath on 04/11/2015
    /**
    Submit a Customer Sentiment Feedback
    
    - parameter EID:
    - parameter Rate:
    - parameter Comment:
    - parameter ContactMe:
    - parameter Source:
    */
    public func customerSentimentFeedback(rate: String, comment: String, source: String = "IT Support Mobile App - iOS", contactme: String, callback: () -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        // Validate parameters
        //if !ValidationUtils.validateStringNotEmpty(comment, errorCallback) { return }

        let request = createRequest(.POST, addCommonGetParams("CustomerSentiment/Feedback"))
        
        request.parameters = [
            "Rate": rate,
            "Comment": comment,
            "EID": AuthenticationUtil.getUserInfo()!.username,
            "contactMe": contactme,
            "Source": source
        ]
        
        let alertview: UIAlertView = UIAlertView(title: nil, message: "Thank you for your feedback", delegate: nil, cancelButtonTitle: nil)
        alertview.show()

        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            
            alertview.dismissWithClickedButtonIndex(-1, animated: true)
            callback()
            
            }, errorCallback: errorCallback)
    }
    //End of Addition

    //Added by Manjunath on 02/02/2016
    /**
    Get WorkInfo Attachment Data
    
    - parameter workinfo id:
    - parameter attachment name:
    */
    public func getWorkInfoAttachmentData(workInfoId: String, filename: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Incident/GetWorkInfoAttachmentData"))
        
        request.parameters = [
            "WorkInfoID": workInfoId,
            "AttachmentName": filename,
        ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            callback(json)
        }, errorCallback: errorCallback)
    }
    //End of Addition

    /**
    Get attachment data
    
    - parameter incidentNumber: the incident number
    - parameter callback:       the callback block to return a list of activities
    - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func getAttachmentData(workInfoId: String, filename: String,
        callback: (String)->(), errorCallback: (RestError, RestResponse?)->()) {
            self.getWorkInfoAttachmentData(workInfoId, filename: filename, callback: { (json: JSON) -> () in
                
                let attachData = json["AttachmentData"].string
                
                callback(attachData!)
                }, errorCallback: errorCallback)
    }

    //Added by Manjunath on 08/02/2016
    /**
    Send User Details Data
    
    - parameter workinfo id:
    - parameter attachment name:
    */
    public func sendUserDetailsListRequest(firstName: String, lastName: String, eid: String, callback: (JSON) -> (), errorCallback: (RestError, RestResponse?)->()) {
        
        let request = createRequest(.POST, addCommonGetParams("Profile/GetUserDetailList"))
        
        request.parameters = [
            "FirstName": firstName,
            "LastName": lastName,
            "EID": eid,
            "maxLimit": Configuration.sharedConfig.empSearchCount
        ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            callback(json)
            }, errorCallback: errorCallback)
    }
    //End of Addition

    /**
    Get User Details List data
    
    - parameter incidentNumber: the incident number
    - parameter callback:       the callback block to return a list of activities
    - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func getUserDetailsListRequest(firstName: String, lastName: String, eid: String,
        callback: ([EmployeeSearch])->(), errorCallback: (RestError, RestResponse?)->()) {
            self.sendUserDetailsListRequest(firstName, lastName: lastName, eid: eid, callback: { (json: JSON) -> () in
                
                var list = [EmployeeSearch]()
                let data = json
                if let array = data.array {
                    for item in array {
                        list.append(EmployeeSearch.fromJSON(item))
                    }
                }

                callback(list)
                }, errorCallback: errorCallback)
    }

    /**
     Get assets count api call
     
     - parameter callback:       the callback block to return a list of activities
     - parameter errorCallback:  the callback block to return an error and related raw response
    */
    public func getAssetsCount(eid: String, callback: (String)->(), errorCallback: (RestError, RestResponse?)->()) {

        self.getAssetsCountApiCall(eid, callback: { (json: JSON) -> () in
                
            var assetCount : String? = ""
            let data = json
            if let array = data.array {
                for item in array {
                    assetCount = String(item["AssetCount"].numberValue.integerValue)
                }
            }

            callback(assetCount!)
                
        }, errorCallback: errorCallback)
    }

    /**
     Get assets count api call
     
     - parameter callback:      the callback block to return success response data
     - parameter errorCallback: the callback block to return an error and related raw response
     */
    public func getAssetsCountApiCall(eid: String, callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        
            let request = createRequest(.POST, addCommonGetParams("Assets/GetCount"))
            
            request.parameters = [
                "EID": eid
            ]
        
        api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            callback(json)
        }, errorCallback: errorCallback)
    }

    /**
     Get assets list
     
     - parameter callback:      the callback block to return a list of incident requests
     - parameter errorCallback: the callback block to return an error and related raw response
     */
    public func getAssetsListParsed(Callback callback: ([Assets])->(), errorCallback: (RestError, RestResponse?)->()) {
        self.getAssetsList(CallBack: { (json: JSON) -> () in
            
            var list = [Assets]()
            let data = json
            if let array = data.array {
                for item in array {
                    list.append(Assets.fromJSON(item))
                }
            }
            
            // Update cache
            self.cachedAssetsRequests = list
            callback(list)
            
        }, errorCallback: errorCallback)
    }

    /**
     Get assets list data
     
     - parameter status:        The status filter. Default "Assigned,In Progress"
     - parameter maxRecords:    The number of records to request. Default 25.
     - parameter callback:      the callback block to return success response data
     - parameter errorCallback: the callback block to return an error and related raw response
     */
    public func getAssetsList(CallBack callback: (JSON)->(), errorCallback: (RestError, RestResponse?)->()) {
        let request = createRequest(.POST, addCommonGetParams("Assets/GetList"))
        
        let username = AuthenticationUtil.getUserInfo()?.username ?? ""
        
        request.parameters = [
            "EID": username
        ]
        
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: { (json, response) -> () in
            callback(json)
        }, errorCallback: errorCallback)
    }

}