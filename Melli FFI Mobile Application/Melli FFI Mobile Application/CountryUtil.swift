//
//  CountryUtil.swift
//  Meli FFI Mobile Application
//
//  Created by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

/**
*  Struct used to store pairs of country code and its name
*/
public struct Locale {
    public let countryCode: String
    public let countryName: String
}

/**
* Utility that helps to define and get current country code
*
* @author TCASSEMBLER
* @version 1.0
*/
public class CountryUtil: NSObject, CLLocationManagerDelegate {
    
    /// CoreLocation utilities instances
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var geocoder: CLGeocoder!
    
    // callback used to return country code
    var success: ((String)->())?
    var failure: ((NSError) -> ())?

    /// JSON that contains country codes as keys and countries as a country names
    var countriesMappings: JSON?

    public override init() {
        super.init()
        initialize()
    }
    
    /**
    Creates required utility instances
    */
    func initialize() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        geocoder = CLGeocoder()
    }

    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        } else if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
            failure?(NSError(domain: applicationErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No permission to access GPS"]))
            success = nil
            failure = nil
        }
    }

    /**
    Locations changed. Can define current country.
    */
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty || locations.count == 0 {
            return
        }
        currentLocation = locations[0]
        
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
            
            if placemarks == nil {
                self.failure?(error!)
                self.success = nil
                self.failure = nil
                self.locationManager.stopUpdatingLocation()
                return
            }
            
            //let currentLocPlacemark = placemarks[0] as! CLPlacemark
            let currentLocPlacemark = CLPlacemark(placemark: (placemarks?[0])!)
            print("Current country: \(currentLocPlacemark.country)")
            print("Current country code: \(currentLocPlacemark.ISOcountryCode)")
            if let countryCode = currentLocPlacemark.ISOcountryCode {
                self.success?(countryCode)
            } else {
                self.failure?(NSError(domain: applicationErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Unkown location"]))
            }
            self.success = nil
            self.failure = nil
            self.locationManager.stopUpdatingLocation()
        })
    }
    
    /**
    Get current country code
    
    - parameter callback: the callback used to return the current country code
    */
    public func getCurrentCountryCodeWithSuccess(success: (String)->(), failure: (NSError) -> ()) {
        self.success = success
        self.failure = failure
        locationManager.requestWhenInUseAuthorization()
    }
    
    /**
    Get list of all countries
    
    - returns: the list of Locales
    */
    public func locales() -> [Locale] {
        
        var locales = [Locale]()
        for localeCode in NSLocale.ISOCountryCodes() {
            let countryName = NSLocale.systemLocale().displayNameForKey(NSLocaleCountryCode, value: localeCode)!
            let countryCode = localeCode 
            let locale = Locale(countryCode: countryCode, countryName: countryName)
            locales.append(locale)
        }
        return locales
    }
    
    /**
    Prints all counties codes and names
    */
    public func printAllCountries() {
        print("(")
        for l in self.locales() {
            print("{\"\(l.countryCode)\": \"\(l.countryName)\"},")
        }
        print(")")
    }
    
    public func getMappings() -> JSON {
        if countriesMappings == nil {
            let path = NSBundle.mainBundle().pathForResource("CountriesMappings", ofType: "json")
            countriesMappings = JSON(data: NSData(contentsOfFile: path!)!)
            print(countriesMappings)
        }
        return countriesMappings!
    }
    
    /**
    Get country name by given country code
    
    - parameter code: the country code
    
    - returns: country name or nil if the code cannot be found
    */
    public func getCountryByCode(code: String) -> String? {
        if let name = getMappings()[code].string {
            return name
        }
        return nil
    }
}