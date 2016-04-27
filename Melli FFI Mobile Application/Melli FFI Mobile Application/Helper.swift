//
//  Helper.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/13/15.
//  Updated by Nikita Rodin on 05/08/15
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

let applicationErrorDomain = "applicationErrorDomain"

/*!
Represents the view controller class extension.

@author mohamede1945
@version 1.0
*/
extension UIViewController {

    /**
    Creates navigation item

    - parameter text: The text

    - returns: the navigation item.
    */
    func createNavigationItem(text: String) -> UIBarButtonItem {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "bar-item-bg"), forState: .Normal)
        button.setTitle(text, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.sizeToFit()
        button.bounds = CGRect(x: 0, y: 0, width: button.bounds.width + 20, height: 33)
        return UIBarButtonItem(customView: button)
    }

    /**
    creates masked navigation item.

    - parameter text: The text

    - returns: the masked navigation item.
    */
    func createMaskedNavigationItem(text: String) -> UIBarButtonItem {
        let button = UIButton(type: .System)
        button.setTitle(text, forState: .Normal)
        button.titleLabel?.font = UIFont.mediumOfSize(17)
        button.sizeToFit()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(white: 0, alpha: 0.5).CGColor, UIColor(white: 0, alpha: 1)]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = button.bounds
        button.layer.mask = gradient
        return UIBarButtonItem(customView: button)
    }

    /**
    Add back button item.
    */
    func addBackItem() {
        let barItem = createNavigationItem("back".localized)
        let button = barItem.customView as! UIButton
        button.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = barItem
    }

    /**
    back button tapped.
    */
    func backButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }

    /**
    Navigate to item

    - parameter item: The item
    */
    func navigateTo(item: MenuViewController.MenuItem) {
        let menu = MenuViewController.menus[item]!
        let controller = storyboard?.instantiateViewControllerWithIdentifier(menu.controllerName)
        if let controller = controller as? DisabledViewController {
            controller.item = menu
        }
        navigationController?.pushViewController(controller!, animated: true)
    }
}

extension UIFont {

    /**
    Gets medimum font.

    - parameter size: The size

    - returns: the font.
    */
    class func mediumOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }

    /**
    Gets light font.

    - parameter size: The size

    - returns: the font.
    */
    class func lightOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }

    /**
    Gets thin font.

    - parameter size: The size

    - returns: the font.
    */
    class func thinOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Thin", size: size)!
    }

    /**
    Returns the size of the string

    - parameter string: the string to measure.
    - parameter width:  the width of the string.

    - returns: the size of the string.
    */
    func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return string.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}

extension UIColor {

    /*!
    Creates new color with RGBA values from 0-255 for RGB and a from 0-1

    :param: r the red color
    :param g the green color
    :param: b the blue color
    :param: a the alpha color
    */
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }

    /*!
    Creates new color with RGBA values from 0-255 for RGB and a from 0-1

    :param: g the gray color
    :param: a the alpha color
    */
    convenience init(gray: CGFloat, a: CGFloat = 1) {
        self.init(r: gray, g: gray, b: gray, a: a)
    }

    /*!
    Gets the identify color of the application.

    :returns: The identity color of the application.
    */
    class func identity() -> UIColor {
        return UIColor(r: 232, g: 52, b: 23)
    }

    /**
    Creates a 1 pixel image from the color.

    - returns: the 1 pixel image of the color.
    */
    func image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension String {
    /*!
    Trim string from while spaces and new lines.

    :returns: the trimmed string.
    */
    func trimmedString() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    /// Gets the localized string for self as the localization key.
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /// Removes the starting characters from string
    func chopPrefix(count: Int = 1) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(count))
    }
}

extension UIView {

    /**
    Add auto layout subview.
    
    - parameter subview: the subview
    */
    func addAutoLayoutSubview(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    /**
    Add leading constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentLeadingConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add trailing constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentTrailingConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add top constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentTopConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add bottom constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentBottomConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add center X constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentCenterXConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add Center Y constraint to parent.
    - parameter view: the child view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addParentCenterYConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add height constraint.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addHeightConstraint(value: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add width constraint.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addWidthConstraint(value: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Pin the view to parent horizontally.
    - parameter view: the child view.
    - parameter leadingValue: the constant value to add to leading.
    - parameter trailingValue: the constant value to add to trailing.
    - returns: the created constraints.
    */
    func pinParentHorizontal(view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentLeadingConstraint(view, value: leadingValue))
        array.append(addParentTrailingConstraint(view, value: trailingValue))
        return array
    }

    /**
    Pin the view to parent vertically.
    - parameter view: the child view.
    - parameter topValue: the constant value to add to leading.
    - parameter bottomValue: the constant value to add to trailing.
    - returns: the created constraints.
    */
    func pinParentVertical(view: UIView, topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentTopConstraint(view, value: topValue))
        array.append(addParentBottomConstraint(view, value: bottomValue))
        return array
    }

    /**
    Pin the view to parent.
    - parameter view: the child view.
    - parameter leadingValue: the constant value to add to leading.
    - parameter trailingValue: the constant value to add to trailing.
    - parameter topValue: the constant value to add to leading.
    - parameter bottomValue: the constant value to add to trailing.
    - returns: the created constraints.
    */
    func pinParentAllDirections(view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0,
        topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint]{
            var array: [NSLayoutConstraint] = []
            array += pinParentHorizontal(view, leadingValue: leadingValue, trailingValue: trailingValue)
            array += pinParentVertical(view, topValue: topValue, bottomValue: bottomValue)
            return array
    }

    /**
    Center in container
    - parameter view: the child view.
    - parameter centerX: the constant value to add to center x.
    - parameter centerY: the constant value to add to center y.
    - returns: the created constraints.
    */
    func addParentCenter(view: UIView, centerX: CGFloat = 0, centerY: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentCenterXConstraint(view, value: centerX))
        array.append(addParentCenterYConstraint(view, value: centerY))
        return array
    }


    /**
    Add right constraint to sibling.
    - parameter left: the left view.
    - parameter right: the right view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addSiblingHorizontalContiguous(left left: UIView, right: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: right,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: left,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add vertical spacing constraint to sibling.
    - parameter top: the top view.
    - parameter bottom: the bottom view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addSiblingVerticalContiguous(top top: UIView, bottom: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: bottom,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: top,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add equal width constraint to sibling.
    - parameter view1: the first view.
    - parameter view2: the second view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addEqualWidthConstraint(view1 view1: UIView, view2: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view1,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view2,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add equal height constraint to sibling.
    - parameter view1: the first view.
    - parameter view2: the second view.
    - parameter value: the constant value to add.
    - returns: the created constraint.
    */
    func addEqualHeightConstraint(view1 view1: UIView, view2: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view1,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view2,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }

    /**
    Add equal size constraint to sibling.
    - parameter view1: the first view.
    - parameter view2: the second view.
    - parameter widht: the constant value to add to the width.
    - parameter height: the constant value to add to the height.
    - returns: the created constraints.
    */
    func addEqualSizeConstraints(view1 view1: UIView, view2: UIView, width: CGFloat = 0, height: CGFloat = 0) -> [NSLayoutConstraint] {
        var array: [NSLayoutConstraint] = []
        array.append(addEqualHeightConstraint(view1: view1, view2: view2, value: height))
        array.append(addEqualWidthConstraint(view1: view1, view2: view2, value: width))
        return array
    }

    /**
    Add size constraint.
    - parameter widht: the constant value to add to the width.
    - parameter height: the constant value to add to the height.
    - returns: the created constraints.
    */
    func addSizeConstraint(width width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        var array: [NSLayoutConstraint] = []
        array.append(addWidthConstraint(width))
        array.append(addHeightConstraint(height))
        return array
    }
}

/**
* Extension to display alerts
*
* - Author: Nikita Rodin
* :version: 1.0
*/
extension UIViewController {
    
    /**
    displays alert with specified title & message
    
    - parameter message: alert message
    - parameter title: alert title
    */
    func showAlert(message: String, title: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// ios8 separator inset fix
class ZeroMaringsTableView : UITableView {
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
}

// ios8 separator inset fix
class ZeroMarginsCell: UITableViewCell {
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
}

/**
 * Extension to NSData
 *
 * - Author: Manjunath M
 */
extension NSData    {
    /// Base64String conversion
    func base64String() -> String   {
        return base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
}