//
//  HelpfulFunctions.swift
//  Melli FFI Mobile Application
//
//  Created by Alexander Volkov on 06.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
A set of helpful functions and extensions
*/

/**
* Extenstion adds helpful methods to String
*
* @author Alexander Volkov
* @version 1.0
*/
extension String {
    
    /// MD5 hash sum for the string
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return hash as String
    }
    
    /**
    Get string without spaces at the end and at the start.
    
    - returns: trimmed string
    */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /** Checks if string contains given substring
    
    - returns: true if the string contains given substring
    */
    func contains(substring: String) -> Bool{
        if let temp = self.rangeOfString(substring){
            return true
        }
        return false
    }
    
    /**
    Creates attributed string for address labels
    
    - returns: NSMutableAttributedString
    */
    func createAttributedAddressString() -> NSMutableAttributedString {
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: self, attributes: [
            NSParagraphStyleAttributeName: paragrahStyle
            ])
        return attributedString
    }
    
    /**
    Shortcut method for stringByReplacingOccurrencesOfString
    
    - parameter target:     the string to replace
    - parameter withString: the string to add instead of target
    
    - returns: a result of the replacement
    */
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString,
            options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /**
    Checks if the string is number
    
    - returns: true if the string presents number
    */
    func isNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let number = formatter.numberFromString(self) {
            return true
        }
        return false
    }
    
    /**
    Checks if the string is positive number
    
    - returns: true if the string presents positive number
    */
    func isPositiveNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let number = formatter.numberFromString(self) {
            if number > 0 {
                return true
            }
        }
        return false
    }
    
    /**
    Get URL encoded string.
    
    - returns: URL encoded string
    */
    public func urlEncodedString() -> String {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet;
        set.removeCharactersInString(":?&=@+/'");
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set as NSCharacterSet)!
    }
}

/**
* Extenstion adds helpful methods to NSDate
*
* @author Alexander Volkov
* @version 1.0
*/
extension NSDate {
    
    /**
    Get NSDate that corresponds to the start of current day.
    
    - returns: the date
    */
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day], fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        var date = nextDayStart()
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
    
    func nextDayStart() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfDay(), options: NSCalendarOptions())!
        return date
    }
    
    /**
    Get NSDate that corresponds to the start of current month.
    
    - returns: the date
    */
    func beginningOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year],
            fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    /**
    Get next month date.
    
    - returns: the date
    */
    func nextMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfMonth(),
            options: NSCalendarOptions())!
        return date
    }
    
    /**
    Get previous month date.
    
    - returns: the date
    */
    func previousMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = -1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfMonth(),
            options: NSCalendarOptions())!
        return date
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = daysToAdd
        
        let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())!
        return date
    }
    
    /**
    Compares current date with the given one down to the seconds.
    If date==nil, then always return false
    
    - parameter date: date to compare or nil
    
    - returns: true if the dates has equal years, months, days, hours, minutes and seconds.
    */
    func sameDate(date: NSDate?) -> Bool {
        if let d = date {
            let calendar = NSCalendar.currentCalendar()
            if NSComparisonResult.OrderedSame == calendar.compareDate(self, toDate: d, toUnitGranularity: NSCalendarUnit.Second) {
                return true
            }
            
        }
        return false
    }
    
    /**
    Check if current date is after the given date
    
    - parameter date: the date to check
    
    - returns: true - if current date is after
    */
    func isAfter(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    /**
    Check if the date corresponds to the same day
    
    - parameter date: the date to check
    
    - returns: true - if the date has same year, month and day
    */
    func isSameDay(date:NSDate) -> Bool {
        let date1 = self
        let calendar = NSCalendar.currentCalendar()
        let comps1 = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day], fromDate:date1)
        let comps2 = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day], fromDate:date)
        
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
}

extension Bool {
    
    /**
    Get random boolean value.
    
    - returns: random value
    */
    static func random() -> Bool {
        return arc4random_uniform(10) > 5
    }
}

extension Int {
    
    /**
    Get random value.
    
    - parameter base: maximum random value
    
    - returns: random value
    */
    static func random(base: UInt32) -> Int {
        return Int(arc4random_uniform(base))
    }
    
}

/**
Delays given callback invokation

- parameter time:     the delay in seconds
- parameter callback: the callback to invoke after 'delay' seconds
*/
func delay(delay: NSTimeInterval, callback: ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
    dispatch_after(popTime, dispatch_get_main_queue(), {
        callback()
    })
}

/**
Shows an alert with the title and message.

- parameter title:   the title
- parameter message: the message
*/
func showAlert(title: String, message: String) {
    let myAlertView = UIAlertView()
    myAlertView.title = title
    myAlertView.message = message
    myAlertView.addButtonWithTitle("ok".localized)
    myAlertView.show()
}

/**
*  Helper class for regular expressions
*
* @author Alexander Volkov
* @version 1.0
*/
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: [],
            range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

// Define operator for simplisity of Regex class
infix operator ≈ { associativity left precedence 140 }
func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

/**
* Class for a showing errors inside a view.
*
* @author Alexander Volkov
* @version 1.0
*/
class ErrorView: UIView {
    
    // error message label
    var label: UILabel!
    
    var message: String?
    var didShow = false
    var parentView: UIView?
    
    /**
    Show given error message in given view
    
    - parameter errorMessage: the error message
    - parameter parentView:   the view
    */
    class func show(errorMessage: String, inView parentView: UIView) {
        let view = ErrorView(message: errorMessage, parentView: parentView)
        view.show()
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    init(message: String, parentView: UIView) {
        super.init(frame: parentView.bounds)
        
        self.message = message
        self.parentView = parentView
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(r: 228, g: 229, b: 231)
        
        label = UILabel()
        label.center = self.center
        label.frame.size.width = self.frame.width
        label.frame.size.height = 30
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        let string = NSAttributedString(string: message ?? "Unknown_error".localized, attributes: [
            NSForegroundColorAttributeName: UIColor(r: 30, g: 36, b: 49),
            NSFontAttributeName: UIFont.lightOfSize(18)])
        
        label.attributedText = string
        
        self.addSubview(label)
        
        let view = label
        let containerView = self
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1.0,
            constant: 0))
        
    }
    
    func terminate() {
        if !didShow { return }
        UIView.animateWithDuration(0.25, animations: { _ in
            self.alpha = 0.0
        }, completion: { success in
            self.removeFromSuperview()
        })
    }
    
    func show() {
        didShow = true
        if let view = parentView {
            view.addSubview(self)
            return
        }
        UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
    }
}

/**
* Class for a general loading view (for api calls).
*
* @author Alexander Volkov
* @version 1.0
*/
class LoadingView: UIView {
    
    var activityIndicator:UIActivityIndicatorView!
    
    /*
    not yet implemented, but may want a message to appear on the loading screen
    that is specific to the data being loaded.
    */
    var message:String?
    var terminated = false
    var didShow = false
    var parentView:UIView?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    init(message:String,parentView:UIView?) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        self.message = message
        self.parentView = parentView
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.alpha = 0.0
    }
    
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animateWithDuration(0.25, animations: { _ in
            self.alpha = 0.0
            }, completion: { success in
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
        })
    }
    
    func showWithDelay() {
        delay(0.25) {
            self.didShow = true
            if !self.terminated {
                if let view = self.parentView {
                    view.addSubview(self)
                    return
                }
                UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
            }
        }
    }
    
    func show() {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return
            }
            UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
        }
    }
    
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.25) {
            self.alpha = 0.75
        }
    }
}

func logout() {
    ServerApi.sharedInstance.clearCache();
    
    AuthenticationUtil.logout { () -> () in
        MenuViewControllerSingleton?.logoutUI()
    }
}
