//
//  SlideMenuViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the slide menu side width delegate protocol.

@author mohamede1945
@version 1.0
*/
@objc
protocol SlideMenuSideWidthDelegate
{
    /**
    Gets slide menu width.

    - returns: the width.
    */
    func slideMenuSideWidth() -> CGFloat
}

/*!
Represents the slide menu view controller class.

@author mohamede1945
@version 1.0
*/
class SlideMenuViewController: UIViewController {

    /**
    Gets the sliding state.

    - Open:        The open state
    - Closed:      The closed state
    - Openning:    The openning state
    - Closing:     The closing state
    - Interactive: The interactive state
    */
    enum SlideState {
        case Open
        case Closed
        case Openning
        case Closing
        case Interactive
    }

    /// Gets the state.
    var state: SlideState = .Closed {
        didSet {
            for view in contentView.subviews {
                view.userInteractionEnabled = state == .Closed
            }
            showingSwipeGesture.enabled = state == .Closed
            hidingSwipeGesture.enabled = state == .Open

            showingPanningGesture.enabled = state != .Open
            hidingPanningGesture.enabled = state != .Closed

            tapGesture.enabled = state == .Open
        }
    }

    /// Gets the width delegate.
    weak var widthDelegate: SlideMenuSideWidthDelegate?

    /// Gets the side controller
    let sideController: UIViewController
    /// Gets the content controller
    var contentController: UIViewController
    /// Gets the animation duration
    var animationDuration = 0.3

    /// Gets the content view
    var contentView = UIView()
    /// Gets the content left constraint
    var contentLeft: NSLayoutConstraint!

    /// Gets the panning gesture recognizer for revealing the menu.
    var showingPanningGesture = UIScreenEdgePanGestureRecognizer()
    /// Gets the panning gesture recognizer for hiding the menu.
    var hidingPanningGesture = UIPanGestureRecognizer()
    /// Gets the swipe gesture recognizer for showing the menu.
    var showingSwipeGesture = UISwipeGestureRecognizer()
    /// Gets the swipe gesture recognizer for hiding the menu.
    var hidingSwipeGesture = UISwipeGestureRecognizer()
    /// Gets the tap gesture recognizer
    var tapGesture = UITapGestureRecognizer()
    /// Gets the interactive width
    var interactiveWidth = CGFloat(0)

    /// Represents the Voice Commands Array
    let voiceCmdArray: NSArray? = NSArray(objects: "Create", "Call", "Chat", "Schedule", "Mail")

    /**
    Creates new instance.

    - parameter sideController: The side controller
    - parameter defaultContent: The default content
    - parameter widthDelegate:  The width delegate

    - returns: the created instance.
    */
    init(sideController: UIViewController, defaultContent: UIViewController, widthDelegate: SlideMenuSideWidthDelegate) {
        self.sideController = sideController
        self.contentController = defaultContent
        self.widthDelegate = widthDelegate

        tapGesture.enabled = false
        showingSwipeGesture.direction = .Right
        hidingSwipeGesture.direction = .Left
        showingPanningGesture.edges = .Left

        contentView.addGestureRecognizer(showingSwipeGesture)
        contentView.addGestureRecognizer(hidingSwipeGesture)
        contentView.addGestureRecognizer(showingPanningGesture)
        contentView.addGestureRecognizer(tapGesture)
        contentView.addGestureRecognizer(hidingPanningGesture)

        super.init(nibName: nil, bundle: nil)

        // add the side controller
        addChildViewController(sideController)
        sideController.didMoveToParentViewController(self)
        sideController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideController.view)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: [], metrics: nil, views: ["view" : sideController.view]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
            options: [], metrics: nil, views: ["view" : sideController.view]))

        // add the content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        contentLeft = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal, toItem: view,
            attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        view.addConstraint(contentLeft)
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal, toItem: contentView,
            attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: [], metrics: nil, views: ["view" : contentView]))

        // create the gestures
        showingSwipeGesture.addTarget(self, action: "showSideMenu")
        hidingSwipeGesture.addTarget(self, action: "hideSideMenu")
        showingPanningGesture.addTarget(self, action: "viewPanned:")
        hidingPanningGesture.addTarget(self, action: "viewPanned:")
        tapGesture.addTarget(self, action: "hideSideMenu")

        setContentViewController(defaultContent)

        loadTemplates()
    }

    /**
    Load templates.
    */
    func loadTemplates() {
        let loadingView = LoadingView(message: "Loading Templates".localized, parentView: self.view)
        loadingView.show()
        ServerApi.sharedInstance.listOfTemplatesParsed(callback: { (root: TemplateRoot) -> () in

            loadingView.terminate()

            }) { (error: RestError, res: RestResponse?) -> () in
                loadingView.terminate()
                ErrorView.show(error.getMessage(), inView: self.view)
        }
    }


    /**
    Always fail, as it is required to be used in code.

    - parameter aDecoder: The a decoder

    - returns: always fails.
    */
    required init?(coder aDecoder: NSCoder) {
        sideController = UIViewController()
        contentController = UIViewController()
        assertionFailure("SlideMenuViewController works only with code")

        super.init(coder: aDecoder)
    }

    /**
    the menu width.

    - returns: the width.
    */
    func menuWidth() -> CGFloat {
        return widthDelegate?.slideMenuSideWidth() ?? view.bounds.width - 40
    }

    /**
    Show side menu.
    */
    func showSideMenu() {
        if state != .Closed {
            return
        }

        state = .Openning
        contentLeft.constant = menuWidth()
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
            options: [], animations: { () -> Void in
                self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.state = .Open
        }
        
    }

    /**
    Hide side menu.
    */
    func hideSideMenu() {
        if state != .Open {
            return
        }

        state = .Closing
        contentLeft.constant = 0
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
            options: [], animations: { () -> Void in
                self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.state = .Closed
        }
    }

    /**
    View has been panned.

    - parameter gesture: The gesture
    */
    func viewPanned(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            interactiveWidth = menuWidth()
            if state == .Open {
                gesture.setTranslation(CGPointMake(interactiveWidth, 0), inView: gesture.view)
            }

            state = .Interactive
        case .Changed:
            let translation = gesture.translationInView(gesture.view!).x
            contentLeft.constant = max(0, min(translation, interactiveWidth))

            view.layoutIfNeeded()
        case .Ended, .Cancelled, .Failed:

            let velocity = gesture.velocityInView(gesture.view).x

            let open: Bool
            if abs(velocity) < 500 {
                let percentage = min(1, (interactiveWidth - contentLeft.constant) / interactiveWidth)
                open = percentage < 0.5
            } else {
                open = velocity > 0
            }
            let totalDistance = open ? (interactiveWidth - contentLeft.constant) : contentLeft.constant
            let normalizedVelocity = velocity / totalDistance
            contentLeft.constant = open ? interactiveWidth : 0

            UIView.animateWithDuration(animationDuration, delay: 0,
                usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: [], animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }) { (finished) -> Void in
                    self.state = open ? .Open : .Closed
            }
        default:
            break

        }
    }

    /**
    Set content view controller.

    - parameter newController: The new controller
    */
    func setContentViewController(newController: UIViewController) {
        // delete old
        if contentController.parentViewController != nil {
            contentController.willMoveToParentViewController(nil)
            contentController.removeFromParentViewController()
            contentController.view.removeFromSuperview()
        }

        contentController = newController

        // add the new
        addChildViewController(contentController)
        contentController.didMoveToParentViewController(self)
        contentController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentController.view)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: [], metrics: nil, views: ["view" : contentController.view]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
            options: [], metrics: nil, views: ["view" : contentController.view]))

        hideSideMenu()
    }
    
    /**
    View did load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "slideMenuTapped", name:"slidemenunotification".localized, object: nil)
    }
    
    /**
    View will Appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /** 
    View did disapper
    */
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    /**
    Slide Menu Tapped 
    */
    func slideMenuTapped()  {
        /* Voice Recognition Calls */
        
//        VoiceRecogniser.sharedInstance().stringArray = voiceCmdArray! as [AnyObject]
//        VoiceRecogniser.sharedInstance().delegate = self
//        VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "SlideViewClassOpenEarsDynamicLanguageModel"
//        VoiceRecogniser.sharedInstance().changePathToSuccessfullyGeneratedModel()
        
        //VoiceRecogniser.sharedInstance().startListening()
    }
    
    /**
    VoiceRecogniser Delegate Method
    */
    /*func voiceRecogniser(voicerecogniser: VoiceRecogniser!, recognisedString string: String!) {
        print("Voice string: \(string)")
        if string == "Create" /* create request*/   {

        }
        else if string == "Chat" /* chat */ {

        }
        else if string == "Mail" /* email */   {

        }
        else if string == "Schedule" /* schedule */ {

        }
        else if string == "Call"    /* call */  {

        }
        
        //VoiceRecogniser.sharedInstance().stopListening()
    }*/
}

/**
* Helpful method
*
* @author mohamede1945, Alexander Volkov
* @version 1.1
*
* changes:
* 1.1:
* - logoutUI method
*/

extension UIViewController
{
    /// gets the slide menu controller.
    var slideMenuController: SlideMenuViewController? {
        var parent: UIViewController? = self
        while (parent != nil) {
            if let parent = parent as? SlideMenuViewController {
                return parent
            }
            parent = parent?.parentViewController
        }
        return nil
    }
    
    /**
    Change UI as if user logged out
    */
    func logoutUI() {
        self.slideMenuController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    Show side menu button tapped.
    */
    @IBAction func showSideMenuButtonTapped() {
        slideMenuController?.showSideMenu()
    }
}