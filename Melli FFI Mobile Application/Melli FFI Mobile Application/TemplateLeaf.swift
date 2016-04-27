//
//  TemplateLeaf.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/19/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation


/**
Represents the template leaf class.

@author mohamede1945

@version 1.0
*/
public class TemplateLeaf : TemplateNode {

    /// Represents the template id property.
    let templateId: String
    /// Represents the instance id property.
    let instanceId: String
    /// Represents the usedby acs property.
    let usedbyACS: String
    /// Represents the used by aero property.
    let usedByAERO: String
    /// Represents the used by corp property.
    let usedByCORP: String
    /// Represents the used by pmt property.
    let usedByPMT: String
    /// Represents the used by ts property.
    let usedByTS: String
    /// Represents the internal it property.
    let internalIT: String
    /// Represents the keywords property.
    let keywords: String
    /// Represents the template name property.
    let templateName: String

    /**
    Initialize new instance with name, template id, instance id, usedby acs, used by aero,
    used by corp, used by pmt, used by ts, internal it, keywords and template name.

    - parameter name:         The name parameter.
    - parameter templateId:   The template id parameter.
    - parameter instanceId:   The instance id parameter.
    - parameter usedbyACS:    The usedby acs parameter.
    - parameter usedByAERO:   The used by aero parameter.
    - parameter usedByCORP:   The used by corp parameter.
    - parameter usedByPMT:    The used by pmt parameter.
    - parameter usedByTS:     The used by ts parameter.
    - parameter internalIT:   The internal it parameter.
    - parameter keywords:     The keywords parameter.
    - parameter templateName: The template name parameter.

    - returns: The new created instance.
    */
    init(name: String, templateId: String, instanceId: String,
        usedbyACS: String, usedByAERO: String, usedByCORP: String, usedByPMT: String, usedByTS: String,
        internalIT: String, keywords: String, templateName: String) {
            self.templateId = templateId
            self.instanceId = instanceId
            self.usedbyACS = usedbyACS
            self.usedByAERO = usedByAERO
            self.usedByCORP = usedByCORP
            self.usedByPMT = usedByPMT
            self.usedByTS = usedByTS
            self.internalIT = internalIT
            self.keywords = keywords
            self.templateName = templateName
            super.init(name: name)
    }

    /**
    Initialize new instance with name and json.

    - parameter name: The name parameter.
    - parameter json: The json parameter.

    - returns: The new created instance.
    */
    convenience init(name: String, json: JSON) {
        self.init(name: name,
            templateId: json["HPD_Template_ID"].stringValue,
            instanceId: json["InstanceId"].stringValue,
            usedbyACS: json["COE_UsedbyACS"].stringValue,
            usedByAERO: json["COE_UsedbyAERO"].stringValue,
            usedByCORP: json["COE_UsedbyCORP"].stringValue,
            usedByPMT: json["COE_UsedbyPMT"].stringValue,
            usedByTS: json["COE_UsedbyTS"].stringValue,
            internalIT: json["COE_Internal_IT"].stringValue,
            keywords: json["COE_Keywords"].stringValue,
            templateName: json["TemplateName"].stringValue)
    }

    /**
    Is generic template.

    - returns: True, if it is the generic instance id.
    */
    override func isGenericTemplate() -> Bool {
        let genericId = self.dynamicType.genericTemplateId()
        return genericId == instanceId
    }

    class func genericTemplateId() -> String {
        return BackendService().getDataSource("genericTemplateInstanceId") as! String
    }
}