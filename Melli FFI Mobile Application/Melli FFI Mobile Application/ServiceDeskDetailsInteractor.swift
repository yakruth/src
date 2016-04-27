//
//  ServiceDeskDetailsInteractor.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 8/25/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the service desk details interactor class.

@author mohamede1945

@version 1.0
*/
class ServiceDeskDetailsInteractor: NSObject {

    /// Represents the country manager property.
    let countryManager = CountryUtil()

    /**
    Retrieve service desk details success and failure.

    - parameter success: The success parameter.
    - parameter failure: The failure parameter.
    */
    func retrieveServiceDeskDetails(success success: (JSON, String?) -> (), failure: (NSError) -> ()) {

        let user = AuthenticationUtil.getUserInfo()!

        let loadLocally = { (error: NSError) -> () in

            let path = NSBundle.mainBundle().pathForResource("ConfiguredServiceDesks", ofType: "json")
            let json = JSON(data: NSData(contentsOfFile: path!)!)
            success(json, nil)
        }

        let tryUserCountry = { [weak self] (error: NSError) -> () in
            self?.retrieveServiceDeskDetails(user, country: user.country, success: success, failure: loadLocally)
        }

        // try to get the country from GPS
        countryManager.getCurrentCountryCodeWithSuccess({ [weak self] (code: String) -> () in

            if let country = self?.countryManager.getCountryByCode(code) {
                self?.retrieveServiceDeskDetails(user, country: country, success: success, failure: tryUserCountry)
            } else {
                self?.retrieveServiceDeskDetails(user, country: user.country, success: success, failure: loadLocally)
            }

            }, failure: tryUserCountry)
    }

    /**
    Retrieve service desk details country, success and failure.

    - parameter user:    The user parameter.
    - parameter country: The country parameter.
    - parameter success: The success parameter.
    - parameter failure: The failure parameter.
    */
    func retrieveServiceDeskDetails(user: UserInfo, country: String, success: (JSON, String?) -> (), failure: (NSError) -> ()) {

        ServerApi.sharedInstance.getServiceDeskDetails(user.sbg, sbu: user.sbu, countryCode: country, callback: { (json: JSON) -> () in

            success(json, country)

            }) { (error: RestError, res: RestResponse?) -> () in

                failure(NSError(domain: applicationErrorDomain, code: 0,
                    userInfo: [NSLocalizedDescriptionKey : "Error while accessing the server"]))
        }
        
    }
}
