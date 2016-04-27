//
//  CategorySelectionViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit


//Added by Manjunath on 21/10/2015
var allFavorites = Dictionary<String, TemplateNode>()
//End of Addition

/*!
Represents the category selection view controller protocol.

@author mohamede1945
@version 1.0
*/
protocol CategorySelectionViewControllerDelegate : class {
    /**
    Did choose template.

    - parameter category: The category
    */
    func didChooseTemplate(template: TemplateLeaf)
}

/*!
Represents the category selection view controller class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - Google Analytics support
*/
class CategorySelectionViewController: KeyboardViewController {

    /// Represents the delegate.
    weak var delegate: CategorySelectionViewControllerDelegate?

    /// Represents the category drop down.
    @IBOutlet weak var categoryDropDown: DropDownView!
    /// Represents the category label.
    @IBOutlet weak var categoryLabel: UILabel!
    /// Represents the collection view.
    @IBOutlet weak var collectionView: UICollectionView!
    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!



    /// Represents the breadcrumb data source.
    var breadcurmbDataSource: ArrayDataSource<String, BreadcrumbCollectionViewCell>!

    /// Represents the categories data source.
    var categoriesDataSource: ArrayDataSource<TemplateNode, CategoryTableViewCell>!

    var parentTemplate: TemplateNode?
    
    /**
    View did load
    */
    override func viewDidLoad() {

        super.viewDidLoad()
        
        title = "newRequest".localized
        addBackItem()
        // UI configuration
        categoryLabel.text = "categorySelectionEmpty".localized
        categoryDropDown.textField.enabled = false
        tableView.tableFooterView = UIView()

        // create the breadcrumb
        var items = ["categorySelectionAllResults".localized]
        if let template = parentTemplate {
            items += template.getTemplateBranchNames()
        }
        var breadcurmbs: [String] = []
        for item in items {
            breadcurmbs += [item, ">"]
        }
        breadcurmbs.removeLast()

        //Added by Manjunath on 20/10/2015
        let name = parentTemplate?.name
        if  name == nil   {
            let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
            loadingView.show()
            
            ServerApi.sharedInstance.getFavorite({ (favoriteItems: [String: TemplateNode]) -> () in
                
                loadingView.terminate()
                allFavorites = favoriteItems
                self.tableView.reloadData()
                
                }, errorCallback: { (error: RestError, res: RestResponse?) -> () in
                    loadingView.terminate()
                    //ErrorView.show(error.getMessage(), inView: self.view)
            });
        }
        //End of Addition

        breadcurmbDataSource = ArrayDataSource(items: breadcurmbs, cellReuseIdentifier: "cell",
            configureClosure: { [weak self] (cell, entity, index) -> Void in
                if let count = self?.collectionView.numberOfItemsInSection(index.section)
                    where count - 1 != index.item && index.item % 2 == 0 {
                    cell.label.textColor = UIColor(r: 74, g: 143, b: 222)
                } else if index.item % 2 == 0 {
                    cell.label.textColor = UIColor(r: 32, g: 41, b: 58)
                } else {
                    cell.label.textColor = UIColor(r: 150, g: 150, b: 150)
                }
                cell.label.text = entity
        })
        collectionView.dataSource = breadcurmbDataSource.proxy

        categoriesDataSource = ArrayDataSource(items: [TemplateNode](), cellReuseIdentifier: "cell",
            configureClosure: { [weak self] (cell: CategoryTableViewCell, entity: TemplateNode, index: NSIndexPath) -> Void in
                //Added by Manjunath on 20/10/2015
                cell.indexpath = index
                cell.delegate = self
                //let idValue = entity.name
                let idValue = entity as? TemplateLeaf
                if allFavorites.count != 0 && idValue != nil    {
                    let value = self!.getValueFromFavoriteDictionary(idValue!.templateId)
                    //var newValue = value as? TemplateLeaf
                    //if newValue!.templateId == idValue!.templateId { //self! added
                    if(value)   {
                        cell.starICon.tag = 1
                    }else{
                        cell.starICon.tag = 0
                    }
                }
                else {
                    cell.starICon.tag = 0
                }
                cell.setFavoriteButtonImage()
                //End of Addition
                cell.configureForTemplate(entity)
                cell.configureForTemplate(entity)
            })
        //Added by Manjunath on 26/10/2015
        
        //End of Addition
        tableView.dataSource = categoriesDataSource.proxy
        if let parentTemplate = parentTemplate {
            //Added by Manjunath on 26/10/2015
            if name == "Favorites"    {
                self.parentTemplate!.removeChildNode()
                for (keyString, Favorites) in allFavorites  {
                    //if Favorites.isGenericTemplate()    {
                        self.parentTemplate!.addChildNode(Favorites)
                    //}
                }
            }
            //End of Addition
            categoriesDataSource.allItems = [parentTemplate.sortedChildren()]
            tableView.reloadData()
        }
        else    {
            loadTemplates()
        }
        
    }

    //Added by Manjunath on 26/10/2015
    func getValueFromFavoriteDictionary(keyString: String) -> Bool
    {
        var returnType:TemplateNode?
        if let value = allFavorites[keyString]  {
            return true
        }
        else    {
            return false
        }
    }
    //End of Addtion
    
    func loadTemplates() {
        let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
        loadingView.show()
        ServerApi.sharedInstance.listOfTemplatesParsed(callback: { (root: TemplateRoot) -> () in

            loadingView.terminate()

            self.parentTemplate = root
            self.categoriesDataSource.allItems = [root.sortedChildren()]
            
            let currentTemplate: TemplateNode
            currentTemplate = TemplateNode(name: "Favorites")
            self.categoriesDataSource.allItems[0][1] = currentTemplate;
            
            //Added by Manjunath on 28/10/2015
            /*swap(&self.categoriesDataSource.allItems[0][1], &self.categoriesDataSource.allItems[0][4])
            swap(&self.categoriesDataSource.allItems[0][2], &self.categoriesDataSource.allItems[0][4])
            swap(&self.categoriesDataSource.allItems[0][3], &self.categoriesDataSource.allItems[0][4])*/
            //End of Addition
            
            self.tableView.reloadData()

            }) { (error: RestError, res: RestResponse?) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        }
    }

    /**
    View will appear.

    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Category Selection Screen"
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: animated)
            }
        }
        self.tableView.reloadData()
    }
}

extension CategorySelectionViewController : UITableViewDelegate {

    /**
    row selected.

    - parameter tableView: The table view
    - parameter indexPath: The index path
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let template = categoriesDataSource.itemAtIndexPath(indexPath)
        if let template = template as? TemplateLeaf {
            delegate?.didChooseTemplate(template)
        } else {
            // open new category.
            if let categoryVC = storyboard?.instantiateViewControllerWithIdentifier("categorySelection") as? CategorySelectionViewController {
                categoryVC.delegate = delegate
                categoryVC.parentTemplate = template
                //categoryVC.allFavorites = allFavorites //Added by Manjunath on 26/10/2015
                navigationController?.pushViewController(categoryVC, animated: true)
            }
        }
    }

    /**
    Height of a row.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the height of a row.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let template = categoriesDataSource.itemAtIndexPath(indexPath)
        let size = UIFont.systemFontOfSize(18).sizeOfString(template.name, constrainedToWidth: tableView.bounds.width - 65)
        return ceil(size.height) + 22
    }
}

extension CategorySelectionViewController : UICollectionViewDelegateFlowLayout {

    /**
    Size of an item.

    - parameter collectionView:       The collection view
    - parameter collectionViewLayout: The collection view layout
    - parameter indexPath:            The index path

    - returns: the size of an item.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let item = breadcurmbDataSource.itemAtIndexPath(indexPath)
            let size = UIFont.lightOfSize(11).sizeOfString(item, constrainedToWidth: collectionView.bounds.width)
            return CGSize(width: ceil(size.width), height: 14)
    }

    /**
    shall highlight an item.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path

    - returns: true if it should.
    */
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.item % 2 == 0) && indexPath.item != (collectionView.numberOfItemsInSection(indexPath.section) - 1)
    }

    /**
    Item has been selected.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        var template = parentTemplate
        var count = 0
        while template != nil {
            template = template?.parent
            count++
        }

        if let controllers = navigationController?.viewControllers  {
            let index = indexPath.item / 2 + controllers.count - count
            navigationController?.popToViewController(controllers[index], animated: true)
        }
    }
}

//Added by Manjunath on 20/10/2015
extension CategorySelectionViewController : CategoryTableViewCellDelegate
{
    /**
    Favorite is On.
    
    - parameter controller:      The CategoryTableViewCell
    - parameter favoriteItem:    The favorite item
    */
    func onCallingCreateFavoriteService(cell: CategoryTableViewCell, favoriteItem: String)    {
        let loadingView = LoadingView(message: "Loading".localized, parentView: self.view)
        loadingView.show()
        
        let template = categoriesDataSource.itemAtIndexPath(cell.indexpath!)
        let newtemplate = template as? TemplateLeaf
        ServerApi.sharedInstance.createFavorite(newtemplate!, favoriteItem: favoriteItem, callback: { (json: JSON) -> () in
            
            loadingView.terminate()
            
            //Added by Manjunath on 26/10/2015
            //var template = Favorites(json: json)
            //self.allFavorites[template.templateName] = template
            if favoriteItem == "Yes"    {
                allFavorites[newtemplate!.templateId] = newtemplate
                //cell.starICon.tag = 1
            }
            else if favoriteItem == "No"   {
                //let templateleaf = template as! TemplateLeaf
                allFavorites.removeValueForKey(newtemplate!.templateId)
                //cell.starICon.tag = 0
                
                let name = self.parentTemplate?.name
                if name == "Favorites"   {
                    self.parentTemplate!.removeChildNode()
                    for (keyString, Favorites) in allFavorites  {
                        //if Favorites.isGenericTemplate()    {
                        self.parentTemplate!.addChildNode(Favorites)
                        //}
                    }
                    self.categoriesDataSource.allItems = [self.parentTemplate!.sortedChildren()]
                }
            }
            self.tableView.reloadData()

            
            //End of Addition
            
            }, errorCallback: { (error: RestError, res: RestResponse?) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        });
    }
    
    
    /**
    Favorite needs to be deleted from Array
    
    - parameter controller:      The CategoryTableViewCell
    - parameter favoriteItem:    The favorite item
    */

    func deleteFavoriteFromDictionary(cell: CategoryTableViewCell, favoriteItem: String)    {
        let template = categoriesDataSource.itemAtIndexPath(cell.indexpath!)
        let templateleaf = template as! TemplateLeaf
        allFavorites.removeValueForKey(templateleaf.templateId)
        self.tableView.reloadData()
    }
}
//End of Addition
