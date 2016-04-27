//
//  PagedHorizontalView.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/13/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the paged horizontal view class.

@author mohamede1945
@version 1.0
*/
class PagedHorizontalView: UIView {

    /**
    Awake from nib.
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self

        pageControl.addTarget(self, action: "pageChanged:", forControlEvents: .ValueChanged)
    }

    /// the page control
    @IBOutlet weak var pageControl: UIPageControl!

    /// the collection view
    @IBOutlet weak var collectionView: UICollectionView!

    /// whether or not dragging has ended
    private var endDragging = false

    /// the current page
    var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }

    /*!
    Currnet page changed.

    :param: sender the page control of the action.
    */
    func pageChanged(sender: AnyObject) {
        currentIndex = pageControl.currentPage
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0),
            atScrollPosition: .Left, animated: true)
    }
}


extension PagedHorizontalView : UICollectionViewDelegateFlowLayout {

    /**
    size of the collection view

    - parameter collectionView: the collection view
    - parameter collectionViewLayout: the collection view flow layout
    - parameter indexPath: the index path
    */
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return collectionView.bounds.size
    }

    /**
    scroll view did end dragging

    - parameter scrollView: the scroll view
    - parameter decelerate: wether the view is decelerating or not.
    */
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            endScrolling(scrollView)
        } else {
            endDragging = true
        }
    }

    /**
    Scroll view did end decelerating
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if endDragging {
            endDragging = false
            endScrolling(scrollView)
        }
    }

    /**
    end scrolling
    */
    func endScrolling(scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        currentIndex = Int(page)
    }
    

}