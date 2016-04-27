//
//  AutoResizableCollectionView.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/17/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/// Represents the content size context.
private var ContentSizeContext = UInt8()

/*!
Represents the auto resizable collection view class.

@author mohamede1945
@version 1.0
*/
class AutoResizableCollectionView: UICollectionView {

    /// Represents the height constraint.
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    /**
    Creates a new view with the passed coder.

    - parameter aDecoder: The a decoder

    - returns: the created new view.
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    /**
    Creates a new view with the passed frame.

    - parameter frame: The frame

    - returns: the created new view.
    */
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUp()
    }

    deinit {
        removeObserver(self, forKeyPath: "contentSize", context: &ContentSizeContext)
    }

    /**
    Sets up the view.
    */
    func setUp() {
        addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: &ContentSizeContext)
    }

    /**
    Observe value for key path.

    - parameter keyPath: The key path
    - parameter object:  The object
    - parameter change:  The change
    - parameter context: The context
    */
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            if context == &ContentSizeContext {
                if keyPath == "contentSize" {
                    heightConstraint?.constant = contentSize.height
                }
            }
    }

}
