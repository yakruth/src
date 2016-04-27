//
//  DisjointArrayDataSource.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the cell configurator protocol.

@author mohamede1945
@version 1.0
*/
protocol CellConfigurer {
    /**
    Configure cell with item.

    - parameter item:      The item
    - parameter cell:      The cell
    - parameter indexPath: The index path
    */
    func configureCellForItem(item: AnyObject, cell: UITableViewCell, indexPath: NSIndexPath)
}

/*!
Represents the disjoin array data source class.

@author mohamede1945
@version 1.0
*/
class DisjointArrayDataSource: NSObject, UITableViewDataSource {

    /// the list of disjoint items
    var items: [[AnyObject]]

    /// the cell configurators.
    let cellConfigurers: [(type: AnyClass, reuseIdentifier: String, configurer: CellConfigurer)]

    /**
    Creates new instance

    - parameter items:           The items
    - parameter cellConfigurers: The cell configurers

    - returns: the new instance.
    */
    init(items: [[AnyObject]], cellConfigurers: [(type: AnyClass, reuseIdentifier: String, configurer: CellConfigurer)]) {
        self.items = items
        self.cellConfigurers = cellConfigurers
    }

    /**
    Number of sections in table view.

    - parameter tableView: The table view

    - returns: number of sections.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }

    /**
    Number of rows in section.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: number of rows.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    /**
    Cell for row.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the created cell.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item: AnyObject = itemAtIndexPath(indexPath)
        for configurer in cellConfigurers {
            if item.isKindOfClass(configurer.type) {
                let cell = tableView.dequeueReusableCellWithIdentifier(configurer.reuseIdentifier)
                /*if item.isKindOfClass(RequestActivity) {
                    let nitem : RequestActivity = (item as? RequestActivity)!
                    if nitem.attachedNames.count > 0   {
                        cell = tableView.dequeueReusableCellWithIdentifier("activityAttachlabel")
                    }
                }*/
                configurer.configurer.configureCellForItem(item, cell: cell!, indexPath: indexPath)
                return cell!
            }
        }
        return UITableViewCell()
    }

    /**
    Item at index path.

    - parameter indexPath: The index path

    - returns: the item.
    */
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return items[indexPath.section][indexPath.row]
    }
}

/*!
Represents the generic cell configurator class.

@author mohamede1945
@version 1.0
*/
class GeneralCellConfigurer<ItemType, CellType: UIView> : CellConfigurer {
    /**
    Configure cell closure
    */
    typealias ConfigureCellClosure = (CellType, ItemType, NSIndexPath) -> Void

    /// configure closure
    let configureClosure: ConfigureCellClosure

    /**
    Creates new instance.

    - parameter configureClosure: The configure closure

    - returns: the created instance.
    */
    init(configureClosure: ConfigureCellClosure) {
        self.configureClosure = configureClosure
    }

    /**
    Configure cell for item.

    - parameter item:      The item
    - parameter cell:      The cell
    - parameter indexPath: The index path
    */
    func configureCellForItem(item: AnyObject, cell: UITableViewCell, indexPath: NSIndexPath) {
        let object = item as! ItemType
        let cellView = cell as! CellType
        configureClosure(cellView, object, indexPath)
    }
}