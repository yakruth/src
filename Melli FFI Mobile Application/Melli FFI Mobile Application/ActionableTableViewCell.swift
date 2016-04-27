//
//  ActionableTableViewCell.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/16/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the draggable scroll view class that forward non-dragging events.

@author mohamede1945
@version 1.0
*/
class DraggableScrollView: UIScrollView {

    /**
    Touches began.

    - parameter touches: The touches
    - parameter event:   The event
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesBegan(touches, withEvent: event)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }

    /**
    Touches moved.

    - parameter touches: The touches
    - parameter event:   The event
    */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesMoved(touches, withEvent: event)
        } else {
            super.touchesMoved(touches, withEvent: event)
        }
    }

    /**
    Touches ended.

    - parameter touches: The touches
    - parameter event:   The event
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesEnded(touches, withEvent: event)
        } else {
            super.touchesEnded(touches, withEvent: event)
        }
    }
}

/**
An actionable table view cell that reveals action buttons when swiped.

The following code is recommended to be implemented by consumers.

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RequestTableViewCell,
            let scrollView = cell.scrollView where scrollView.contentOffset.x != 0 {
            return false
        }
        return true
    }
@author mohamede1945

*/
class ActionableTableViewCell: UITableViewCell {

    /// Represents the action table view state changed key.
    static let ActionTableViewStateChangedKey = "ActionTableViewStateChangedKey"

    /// Represents the user dragged or not.
    private var userDragged = false

    /// Represents the cell content view.
    @IBOutlet weak var cellContentView: UIView!

    /// Represents the scroll view.
    var scrollView: UIScrollView?

    /// Represents the actions view.
    private var actionsView: UIView?

    /// The scroll content view
    private var scrollContent: UIView?

    /// The content tap gesture.
    private var tapGesture: UITapGestureRecognizer?

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
    Creates a new view with the passed style and identifier.

    - parameter style:           The style
    - parameter reuseIdentifier: The reuse identifier

    - returns: the created new view.
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    /**
    Sets up the view.
    */
    func setUp() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tableViewStateChanged:",
            name: ActionableTableViewCell.ActionTableViewStateChangedKey, object: nil)
    }

    /**
    Deinitializer.
    */
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ActionableTableViewCell.ActionTableViewStateChangedKey, object: nil)
    }

    /**
    table view state changed.

    - parameter notification: The notification
    */
    func tableViewStateChanged(notification: NSNotification) {
        if let tableView = notification.object as? UITableView where self.tableView == tableView {
            resetScrollView(true)
        }
    }

    /**
    Reset scroll view.

    - parameter animated: The animated
    */
    func resetScrollView(animated: Bool, forceReset: Bool = false) {
        if let scrollView = scrollView where forceReset || (scrollView.contentOffset != CGPoint.zero && userDragged) {
            userDragged = false
            scrollView.setContentOffset(CGPointZero, animated: animated)
            scrollView.scrollEnabled = true
            tapGesture?.enabled = false
        }
    }

    /**
    Sets selected state.

    - parameter selected: The selected
    - parameter animated: The animated
    */
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        scrollView?.scrollEnabled = !selected

        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }

    /**
    Sets highlighted state.

    - parameter highlighted: The highlighted
    - parameter animated:    The animated
    */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        scrollView?.scrollEnabled = !highlighted

        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }

    /**
    Prepare for reuse.
    */
    override func prepareForReuse() {
        super.prepareForReuse()
        resetScrollView(false, forceReset: true)
    }

    /**
    Sets list of actions

    - parameter actions: The actions

    - returns: the created buttons.
    */
    func setActions(actions: [(action: String, color: UIColor, width: CGFloat)]) -> [UIButton] {

        if scrollView == nil {
            let scrollView = DraggableScrollView()
            let actionsView = UIView()
            let scrollContent = UIView()

            actionsView.hidden = true

            scrollView.delegate = self
            scrollView.showsHorizontalScrollIndicator = false

            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollContent.translatesAutoresizingMaskIntoConstraints = false
            actionsView.translatesAutoresizingMaskIntoConstraints = false

            let cellContentIndex = (contentView.subviews ).indexOf(cellContentView)!
            cellContentView.removeFromSuperview()

            contentView.insertSubview(scrollView, atIndex: cellContentIndex)
            scrollView.addSubview(scrollContent)
            scrollContent.addSubview(actionsView)
            scrollContent.addSubview(cellContentView)

            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
                options: [], metrics: nil, views: ["view" : scrollView]))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
                options: [], metrics: nil, views: ["view" : scrollView]))

            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
                options: [], metrics: nil, views: ["view" : scrollContent]))
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
                options: [], metrics: nil, views: ["view" : scrollContent]))

            scrollView.addConstraint(NSLayoutConstraint(item: scrollContent,
                attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal,
                toItem: scrollView, attribute: NSLayoutAttribute.CenterY,
                multiplier: 1, constant: 0))


            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==parent)]",
                options: [], metrics: nil, views: ["view" : cellContentView, "parent" : scrollView]))
            scrollContent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
                options: [], metrics: nil, views: ["view" : cellContentView]))

            scrollContent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
                options: [], metrics: nil, views: ["view" : actionsView]))
            contentView.addConstraint(NSLayoutConstraint(item: actionsView, attribute: NSLayoutAttribute.Trailing,
                relatedBy: .Equal, toItem: contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
            

            self.scrollView = scrollView
            self.actionsView = actionsView
            self.scrollContent = scrollContent

            tapGesture = UITapGestureRecognizer(target: self, action: "cellContentTapped:")
            tapGesture?.enabled = false
            cellContentView.addGestureRecognizer(tapGesture!)
        }

        // remove old buttons
        actionsView?.subviews.map { $0.removeFromSuperview() }

        var totalWidth: CGFloat = 0

        var buttons: [UIButton] = []
        for action in actions {
            let button = UIButton()
            button.setBackgroundImage(action.color.image(), forState: .Normal)
            button.setTitle(action.action, forState: .Normal)

            button.translatesAutoresizingMaskIntoConstraints = false
            actionsView?.addSubview(button)

            actionsView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
                options: [], metrics: ["width": action.width], views: ["view" : button]))
            button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==width)]",
                options: [], metrics: ["width": action.width], views: ["view" : button]))

            buttons.append(button)

            totalWidth += action.width
        }

        if let button = buttons.first {
            actionsView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]",
                options: [], metrics: nil, views: ["view" : button]))
        }

        if let button = buttons.last {
            actionsView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view]|",
                options: [], metrics: nil, views: ["view" : button]))
        }

        for var i = 1; i < buttons.count; i++ {
            actionsView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previous][current]",
                options: [], metrics: nil, views: ["previous" : buttons[i - 1], "current" : buttons[i]]))
        }


        scrollContent?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]-padding-|",
            options: [], metrics: ["padding": totalWidth], views: ["view" : cellContentView]))

        return buttons
    }

    func cellContentTapped(gesture: UITapGestureRecognizer) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }
}

extension ActionableTableViewCell : UIScrollViewDelegate {

    /**
    Scroll view did scroll

    - parameter scrollView: the scroll view
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.x > 0
        actionsView?.hidden = scrollView.contentOffset.x <= 0
    }

    /**
    Scroll view did end dragging.

    - parameter scrollView: the scroll view.
    - parameter decelerate: the decelerate flag.
    */
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            endScrolling(scrollView)
        }
    }

    /**
    Scroll view did end decelerating.

    - parameter scrollView: the scroll view.
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        endScrolling(scrollView)
    }

    /**
    Scroll view ended scrolling.

    - parameter scrollView: scroll view.
    */
    func endScrolling(scrollView: UIScrollView) {
        scrollView.scrollEnabled = scrollView.contentOffset.x == 0
        tapGesture?.enabled = !scrollView.scrollEnabled
    }

    /**
    Scroll view will begin dragging.

    - parameter scrollView: The scroll view
    */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userDragged = true

        actionsView?.hidden = true

        NSNotificationCenter.defaultCenter().postNotificationName(
            ActionableTableViewCell.ActionTableViewStateChangedKey, object: self.tableView)
    }

    /**
    Scroll view will end dragging.

    - parameter scrollView:          the scroll view.
    - parameter velocity:            the velocity
    - parameter targetContentOffset: the target content offset.
    */
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {

            let min: CGFloat = 0
            let max: CGFloat = scrollView.contentSize.width - scrollView.bounds.width
            if scrollView.contentOffset.x < min {
                targetContentOffset.memory.x = min
            } else if scrollView.contentOffset.x > max {
                targetContentOffset.memory.x = max
            } else {
                if abs(targetContentOffset.memory.x - min) < abs(targetContentOffset.memory.x - max) {
                    targetContentOffset.memory.x = min
                } else {
                    targetContentOffset.memory.x = max
                }
            }
    }
}


/*!
Represents the table view cell class extension.

@author mohamede1945
@version 1.0
*/
extension UITableViewCell {

    /// Gets the table view
    var tableView: UITableView? {
        var parent = superview
        while (parent != nil) {
            if let parent = parent as? UITableView {
                return parent
            }
            parent = parent?.superview
        }
        return nil
    }
}