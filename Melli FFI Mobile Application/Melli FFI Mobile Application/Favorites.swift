//
//  Favorites.swift
//  Meli FFI Mobile Application
//
//  Created by Honeywell International Inc on 10/21/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

//Added by Manjunath on 21/10/2015
import Foundation

public class Favorites
{
    let heid: String
    let templateName: String
    let hpdTemplateId: String
    let instanceId: String
    let coehontier1: String
    let coehontier2: String
    let coehontier3: String
    let faultCode: String
    let faultString: String
    
    init (heid: String, templateName: String, hpdTemplateId: String, instanceId: String, coehontier1: String, coehontier2: String, coehontier3: String, faultCode: String, faultString: String) {
        self.heid = heid
        self.templateName = templateName
        self.hpdTemplateId = hpdTemplateId
        self.instanceId = instanceId
        self.coehontier1 = coehontier1
        self.coehontier2 = coehontier2
        self.coehontier3 = coehontier3
        self.faultCode = faultCode
        self.faultString = faultString
    }
    
    convenience init(json: JSON) {
            self.init(heid: json["Eid"].stringValue,
                templateName: json["TemplateName"].stringValue,
                hpdTemplateId: json["HPD_Template_ID"].stringValue,
                instanceId: json["InstanceId"].stringValue,
                coehontier1: json["COE_HONTier1"].stringValue,
                coehontier2: json["COE_HONTier2"].stringValue,
                coehontier3: json["COE_HONTier3"].stringValue,
                faultCode: json["faultcode"].stringValue,
                faultString: json["faultstring"].stringValue)
    }

}
//End of Addition