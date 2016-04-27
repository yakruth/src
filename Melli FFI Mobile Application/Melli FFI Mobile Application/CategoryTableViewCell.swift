//
//  CategoryTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

//Added by Manjunath on 20/10/2015
protocol CategoryTableViewCellDelegate {
    func onCallingCreateFavoriteService(controller: CategoryTableViewCell, favoriteItem: String)
    func deleteFavoriteFromDictionary(controller:CategoryTableViewCell, favoriteItem:String)
}
//End of Addition

/*!
Represents the category table view cell class.

@author mohamede1945
@version 1.0
*/
class CategoryTableViewCell: UITableViewCell {

    //The Delegate: Added by Manjunath on 20/10/2015
    var delegate: CategoryTableViewCellDelegate?
    var indexpath: NSIndexPath?
    //End of Addition
    
    /// The label.
    @IBOutlet weak var label: UILabel!
    /// the icon.
    @IBOutlet weak var icon: UIImageView!

    //Start icon
    @IBOutlet weak var starICon: UIButton!
    
    @IBAction func tappedOnFavorite(sender: AnyObject) {
        //Added by Manjunath on 20/10/2015
        var image: UIImage? = nil
        if starICon.tag == 0    {
            starICon.tag = 1
            image = UIImage(named: "starOn") as UIImage?
            starICon.setImage(image, forState: .Normal)

            if let delegate = self.delegate {
                delegate.onCallingCreateFavoriteService(self, favoriteItem: "Yes")
            }
        }
        else    {
            starICon.tag = 0
            image = UIImage (named: "starOff") as UIImage?
            starICon.setImage(image, forState: .Normal)

            if let delegate = self.delegate {
                //delegate.deleteFavoriteFromDictionary(self, favoriteItem: self.label.text!)
                delegate.onCallingCreateFavoriteService(self, favoriteItem: "No")
            }
        }
        //starICon.tag = starICon.tag == 0 ? 1 : 0
        //starICon.setImage(image, forState: .Normal)
    }
    
    func setFavoriteButtonImage() {
        var image: UIImage? = nil
        if starICon.tag == 1    {
            image = UIImage(named: "starOn") as UIImage?
        }
        else    {
            image = UIImage (named: "starOff") as UIImage?
        }
        starICon.setImage(image, forState: .Normal)
    }
    
    /// The default spacing to use when laying out content in the view.
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsetsZero
        }
        set {
            // does nothing
        }
    }
}


extension CategoryTableViewCell {

    /**
    Configure for template.

    - parameter template: The template parameter.
    */
    func configureForTemplate(template: TemplateNode) {
        // set the name
        label.text = template.name
        label.font = template.isGenericTemplate() ? UIFont.boldSystemFontOfSize(18) : UIFont.systemFontOfSize(18)

        let isLeaf = template is TemplateLeaf
        icon.hidden = !isLeaf
        starICon.hidden = !isLeaf
        accessoryType = isLeaf ? .None : .DisclosureIndicator
    }
}