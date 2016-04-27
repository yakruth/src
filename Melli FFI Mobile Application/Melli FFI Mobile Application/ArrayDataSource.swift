//
//  ArrayDataSource.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/13/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the collection view data source protcol.

@author mohamede1945
@version 1.0
*/
protocol CollectionViewDataSource : class {
    /// the datasource proxy
    var proxy: DataSourceProxy! { get }

    /**
    Gets the number of items in section

    - parameter collectionView: The collection view
    - parameter section:        The section

    - returns: the number of items in section.
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int

    /**
    Gets the number of sections.

    - parameter collectionView: The collection view

    - returns: the number of sections
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int

    /**
    Gets the cell for item at index.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path

    - returns: the cell for the item.
    */
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
}

/*!
Represents the table view data source protocol.

@author mohamede1945
@version 1.0
*/
protocol TableViewDataSource : class {
    var proxy: DataSourceProxy! { get }

    /**
    Gets number of sections in table view.

    - parameter tableView: The table view

    - returns: the number of sections.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int

    /**
    Gets number of rows.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: the number of rows.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int

    /**
    Gets cell for row at index path.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the cell.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}

/*!
Represents the array data source section class.

@author mohamede1945
@version 1.0
*/
protocol ArrayDataSourceSection {
    /// the section item type
    typealias SectionItemType
    /// the list of items for the section.
    var items: [SectionItemType] { get }
}

/*!
Represents the base data source class.

@author mohamede1945
@version 1.0
*/
class BaseDataSource<ItemType, CellType: UIView>: CollectionViewDataSource, TableViewDataSource {

    /// the proxy
    var proxy: DataSourceProxy!

    /**
    Creates new instance.

    - returns: the instance.
    */
    init() {
        self.proxy = DataSourceProxy(self)
    }

    // mark:- UICollectionViewDataSource

    /**
    Number of sections in collection.

    - parameter collectionView: The collection view

    - returns: number of sections.
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    /**
    Number of items in section.

    - parameter collectionView: The collection view
    - parameter section:        The section

    - returns: Number of items.
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assertionFailure("Should be implemented by subclasses")
        return 0
    }

    /**
    Cell for item at index.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path

    - returns: the created cell
    */
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            assertionFailure("Should be implemented by subclasses")
            return UICollectionViewCell()
    }

    // mark:- UITableViewDataSource

    /**
    Number of sections.

    - parameter tableView: The table view

    - returns: the number of sections.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    /**
    Number of rows in section.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: number of rows.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assertionFailure("Should be implemented by subclasses")
        return 0
    }

    /**
    The cell for row.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the cell.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        assertionFailure("Should be implemented by subclasses")
        return UITableViewCell()
    }
}

/*!
Represents the data source proxy class.

@author mohamede1945
@version 1.0
*/
class DataSourceProxy: NSObject, UITableViewDataSource, UICollectionViewDataSource {

    /// the data source
    private unowned var dataSource: protocol<CollectionViewDataSource, TableViewDataSource>

    /**
    Creates new instance

    - parameter dataSource: The data source

    - returns: the new instance.
    */
    init(_ dataSource: protocol<CollectionViewDataSource, TableViewDataSource>) {
        self.dataSource = dataSource
    }

    // MARK: UITableViewDataSource

    /**
    Number of sections

    - parameter tableView: The table view

    - returns: number of sections
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSectionsInTableView(tableView)
    }

    /**
    Number of rows.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: Number of rows.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    /**
    Gets the cell for index.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the created cell.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    // MARK: - UICollectionViewDataSource

    /**
    Gets number of items in a section.

    - parameter collectionView: The collection view
    - parameter section:        The section

    - returns: Number of items.
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }

    /**
    Gets number of sections.

    - parameter collectionView: The collection view

    - returns: Number of sections.
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSectionsInCollectionView(collectionView)
    }

    /**
    Cell for item at index path.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path

    - returns: the cell for the item.
    */
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            return dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
}

/*!
Represents the array data source class.

@author mohamede1945
@version 1.1
* changes:
* 1.1:
* - refactoring: required to allow to nest the class
*/
class ArrayDataSource<ItemType, CellType: UIView> : BaseDataSource<ItemType, CellType> {

    /**
    The configurator closure.
    */
    typealias ConfigureCellClosure = (CellType, ItemType, NSIndexPath) -> Void
    
    /// the reuse id.
    var cellReuseIdentifier: String!
    /// the configurator.
    var configureClosure: ConfigureCellClosure!

    /// the list of items.
    var allItems: [[ItemType]]!

    /// the list of static top cells.
    var staticTopCells: [[UIView]]!
    
    override init() {super.init()}
    
    /**
    Creates new instance

    - parameter items:               The items
    - parameter cellReuseIdentifier: The cell reuse identifier
    - parameter staticTopCells:      The static top cells
    - parameter configureClosure:    The configure closure

    - returns: the created instance
    */
    init(items: [[ItemType]], cellReuseIdentifier: String, staticTopCells: [[UIView]] = [],
        configureClosure: ConfigureCellClosure) {
            super.init()
            configure(items, cellReuseIdentifier: cellReuseIdentifier, staticTopCells: staticTopCells,
                configureClosure: configureClosure)
    }
    
    func configure(items: [[ItemType]], cellReuseIdentifier: String, var staticTopCells: [[UIView]] = [],
        configureClosure: ConfigureCellClosure) {
            assert(items.count == staticTopCells.count || staticTopCells.count == 0,
                "items and staticTopCells should have the same number of elements.")
            if staticTopCells.count == 0 {
                for _ in items {
                    staticTopCells.append([])
                }
            }
            
            self.allItems = items
            self.cellReuseIdentifier = cellReuseIdentifier
            self.configureClosure = configureClosure
            self.staticTopCells = staticTopCells
            for array in staticTopCells {
                for view in array {
                    assert(view is UITableViewCell || view is UICollectionViewCell,
                        "each view in staticTopCells must be either UITableViewCell or UICollectionViewCell")
                }
            }
    }

    /**
    Creates new instance.

    - parameter items:               The items
    - parameter cellReuseIdentifier: The cell reuse identifier
    - parameter staticTopCells:      The static top cells
    - parameter configureClosure:    The configure closure

    - returns: the created instance.
    */
    convenience init(items: [ItemType], cellReuseIdentifier: String, staticTopCells: [UIView] = [],
        configureClosure: ConfigureCellClosure) {
            self.init(items: [items], cellReuseIdentifier: cellReuseIdentifier, staticTopCells: [staticTopCells],
                configureClosure: configureClosure)
    }

    /**
    Gets item at index path.

    - parameter indexPath: The index path

    - returns: the item at index path.
    */
    func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType {
        return allItems[indexPath.section][indexPath.row - staticTopCells[indexPath.section].count]
    }

    /**
    Configure cell.

    - parameter cell:      The cell
    - parameter indexPath: The index path
    */
    func configureCell(cell: CellType, atIndexPath indexPath:NSIndexPath) {
        let item = itemAtIndexPath(indexPath)
        self.configureClosure(cell, item, indexPath)
    }

    // MARK: UITableViewDataSource

    /**
    Number of sections in table view.

    - parameter tableView: The table view

    - returns: number of sections.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allItems.count
    }

    /**
    Number of rows in section.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: Number of rows.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems[section].count + staticTopCells[section].count
    }

    /**
    Gets cell for row at index path.

    - parameter tableView: The table view
    - parameter indexPath: The index path

    - returns: the created cell.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < staticTopCells[indexPath.section].count {
            return staticTopCells[indexPath.section][indexPath.row] as! UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier,
                forIndexPath: indexPath) as! CellType
            configureCell(cell, atIndexPath: indexPath)
            return cell as! UITableViewCell
        }
    }

    // MARK: - UICollectionViewDataSource

    /**
    Gets number of sections.

    - parameter collectionView: The collection view

    - returns: number of sections.
    */
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return allItems.count
    }

    /**
    Gets number of items in section.

    - parameter collectionView: The collection view
    - parameter section:        The section

    - returns: number of items.
    */
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return allItems[section].count + staticTopCells[section].count
    }

    /**
    Gets cell for index path.

    - parameter collectionView: The collection view
    - parameter indexPath:      The index path

    - returns: the created cell.
    */
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if indexPath.item < staticTopCells[indexPath.section].count {
                return staticTopCells[indexPath.section][indexPath.item] as! UICollectionViewCell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier,
                    forIndexPath: indexPath) as! CellType
                configureCell(cell, atIndexPath: indexPath)
                return cell as! UICollectionViewCell
            }
    }
}

/*!
Represents the array sectioned data source class.

@author mohamede1945
@version 1.0
*/
class ArraySectionedDataSource<SectionType: ArrayDataSourceSection, SectionHeaderViewType, ItemType, CellType: UIView
where SectionType.SectionItemType == ItemType> : ArrayDataSource<ItemType, CellType> {

    /**
    *  the configurator closure
    */
    typealias ConfigureSectionClosure = (SectionHeaderViewType, SectionType, Int) -> Void

    /// Gets list of sections
    var sections: [SectionType] {
        didSet {
            allItems = sections.map { $0.items }
        }
    }

    /// configure section closure.
    let configureSectionClosure: ConfigureSectionClosure
    /// section reuse identifier.
    let sectionReuseIdentifier: String

    /**
    Creates new instance.

    - parameter sections:                The sections
    - parameter cellReuseIdentifier:     The cell reuse identifier
    - parameter sectionReuseIdentifier:  The section reuse identifier
    - parameter staticTopCells:          The static top cells
    - parameter configureSectionClosure: The configure section closure
    - parameter configureCellClosure:    The configure cell closure

    - returns: the created instance.
    */
    init(sections: [SectionType], cellReuseIdentifier: String, sectionReuseIdentifier: String,
        staticTopCells: [[UIView]] = [],
        configureSectionClosure: ConfigureSectionClosure,
        configureCellClosure: ConfigureCellClosure) {
            self.sections = sections
            self.sectionReuseIdentifier = sectionReuseIdentifier
            self.configureSectionClosure = configureSectionClosure
            let items = sections.map { $0.items }
            super.init(items: items, cellReuseIdentifier: cellReuseIdentifier,
                staticTopCells: staticTopCells, configureClosure: configureCellClosure)
    }


    /**
    Gets section view at index.

    - parameter parentView: The parent view
    - parameter section:    The section

    - returns: the section view.
    */
    func getSectionViewOf(parentView: UIView, atIndex section: Int) -> SectionHeaderViewType {
        assert(parentView is UITableView || parentView is UICollectionView,
            "each view in staticTopCells must be either UITableView or UICollectionView")

        // get the view
        if let tableView = parentView as? UITableView {
            let sectionView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(
                sectionReuseIdentifier) as! SectionHeaderViewType
            // configure the view
            configureSectionClosure(sectionView, sections[section], section)

            // return the view
            return sectionView
        } else {
            assertionFailure("CollectionView sections not supported yet")
            let collectionView = parentView as! UICollectionView
            
            return collectionView.dequeueReusableSupplementaryViewOfKind("",
                withReuseIdentifier: sectionReuseIdentifier, forIndexPath: NSIndexPath()) as! SectionHeaderViewType
        }
    }
    
}