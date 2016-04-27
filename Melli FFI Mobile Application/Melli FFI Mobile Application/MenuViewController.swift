//
//  MenuViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Modified by Nikita Rodin on 08/05/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit


/// reference to singleton MenuViewController instance
var MenuViewControllerSingleton: MenuViewController?

let DisabledControllerName = "disabled"

/*!
Represents the menu view controller class.

@author mohamede1945, Alexander Volkov
@version 1.1
*
* changes:
* 1.1:
* - integration with server API
*/
class MenuViewController: UIViewController  /* VoiceRecogniserDelegate */ {

    /**
    Menu items

    - Home:        The home
    - Dashboard:   The dashboard
    - MyRequests:  The my requests
    - MyAssets:    The my Assets
    - News:        The news
    - FAQs:        The fa qs
    - NewRequest:  The new request
    - NewChat:     The new chat
    - NewEmail:    The new email
    - NewSchedule: The new schedule
    - NewCall:     The new call
    - Feedback:    The feedback
    */
    enum MenuItem {
        case Home
        case Dashboard
        case MyRequests
        case MyAssets /* Added by H146574 */
        case News
        case FAQs
        case NewRequest
        case NewChat
        case NewEmail
        case NewSchedule
        case NewCall
        case Feedback
        case ITCustomerSentiment    //Added by Manjunath
        case Subscriptions
        
        func getDisabledContentLabel() -> String? {
            switch self {
            case .Dashboard:
                return "Dashboard Functionality"
            case .NewChat:
                return "Chat Integration"
            case .NewSchedule:
                return "Schedule Integration"
            case .MyAssets:
                return "My Assets"
            default:
                return nil
            }
        }
    }

    /**
    *  The menu structure.
    */
    struct Menu {
        /// Represents the item.
        let item: MenuItem
        /// Represents the name.
        let name: String
        /// Represents the image name.
        let imageName: String
        /// Represents the controller name.
        let controllerName: String
    }

    /**
    *  The menu section.
    */
    struct MenuSection : ArrayDataSourceSection {
        /// Represents the name.
        var name: String
        /// Represents the items.
        let items: [MenuItem]
    }

    /// the menus
    static let menus: [MenuItem: Menu] = [
        .Home           : Menu(item: .Home, name: "home".localized, imageName: "menu-home", controllerName: "home"),
        .Dashboard      : Menu(item: .Dashboard, name: "dashboard".localized, imageName: "menu-dashboard", controllerName: DisabledControllerName),
        .MyRequests     : Menu(item: .MyRequests, name: "myRequests".localized, imageName: "menu-requests", controllerName: "requests"),
        .MyAssets     : Menu(item: .MyAssets, name: "myAssets".localized, imageName: "menu-asset", controllerName: "assets"),
        .News           : Menu(item: .News, name: "newsAlerts".localized, imageName: "menu-news", controllerName: "news"),
        .FAQs           : Menu(item: .FAQs, name: "faqs".localized, imageName: "menu-faq", controllerName: "faq"),
        .NewRequest     : Menu(item: .NewRequest, name: "newRequest".localized, imageName: "menu-new-request", controllerName: "newRequest"),
        .NewChat        : Menu(item: .NewChat, name: "newChat".localized, imageName: "menu-new-chat", controllerName: DisabledControllerName),
        .NewEmail       : Menu(item: .NewEmail, name: "newEmail".localized, imageName: "menu-new-email", controllerName: "emailSupport"),
        .NewSchedule    : Menu(item: .NewSchedule, name: "newSchedule".localized, imageName: "menu-new-schedule", controllerName: DisabledControllerName),
        .NewCall        : Menu(item: .NewCall, name: "newCall".localized, imageName: "menu-new-call", controllerName: "phoneSupport"),
        .Feedback       : Menu(item: .Feedback, name: "provideFeedback".localized, imageName: "menu-feedback", controllerName: "feedback"),
        .ITCustomerSentiment    : Menu(item: .ITCustomerSentiment, name: "itCustomerSentiment".localized, imageName: "menu-feedback", controllerName: "itcustomersentiment"), /* Added by Manjunath */
        .Subscriptions  : Menu(item: .Subscriptions, name: "subscriptions".localized, imageName: "menu-feedback", controllerName: "subscriptions")
    ]

    /// the sections
    static let sections: [MenuSection] = [MenuSection(name: "", items: [.Home, .Dashboard, .MyRequests, .MyAssets, .News, .FAQs]),
        MenuSection(name: "Need Support?", items: [.NewRequest, .NewChat, .NewEmail, .NewSchedule, .NewCall]),
        MenuSection(name: "Help us improve your experience", items: [.Feedback, .ITCustomerSentiment]),
        MenuSection(name: "Settings", items: [.Subscriptions])]

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the old index.
    private var oldIndex: NSIndexPath?
    
    /// Represents the last selected index.
    private var lastSelectedIndex: NSIndexPath?

    /// Represents the data source.
    var dataSource: ArraySectionedDataSource<MenuSection, MenuHeaderView, MenuItem, MenuTableViewCell>!

    /// Represents the Voice Commands Array
    //let voiceCmdArray: NSArray? = NSArray(objects: "Create", "Logout", "Call", "Chat", "Schedule", "Mail")

    /**
    View did loaded
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        MenuViewControllerSingleton = self
        
        tableView.registerClass(MenuHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")

        dataSource = ArraySectionedDataSource(sections: MenuViewController.sections, cellReuseIdentifier: "cell",
            sectionReuseIdentifier: "header", configureSectionClosure: { (sectionView, section, index) -> Void in
                if index == 0 {
                    let info = AuthenticationUtil.getUserInfo() ?? UserInfo(username: "")
                    sectionView.setMainText(info.getFullName(), subText: info.email)
                } else {
                    sectionView.setMainText(section.name, subText: nil)
                }
        }, configureCellClosure: { (cell, entity, index) -> Void in
            cell.configure(MenuViewController.menus[entity]!)
        })
        tableView.dataSource = dataSource.proxy

    }

    /**
    View did appear.

    - parameter animated: The animated
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRowAtIndexPath(defaultIndexPath(), animated: animated, scrollPosition: .Top)
       
        //VoiceRecogniser.sharedInstance().stringArray = voiceCmdArray! as [AnyObject]
        //VoiceRecogniser.sharedInstance().delegate = self
        //VoiceRecogniser.sharedInstance().usingStartingLanguageModel = 1
        //VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "MenuClassOpenEarsDynamicLanguageModel"
        //VoiceRecogniser.sharedInstance().loadOpenEars()
        
        //VoiceRecogniser.sharedInstance().startListening()
    }

    /**
    View will appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /**
    View will disappear
    */
    override func viewWillDisappear(animated: Bool) {
        //VoiceRecogniser.sharedInstance().stopListening()
    }
    
    /**
    Default index path.

    - returns: the default index path.
    */
    func defaultIndexPath() -> NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    
    /**
    */
    func navigateTheScreen(indexPath: NSIndexPath)    {
        if let controller = createContentControllerAtIndex(indexPath) {
            self.slideMenuController?.setContentViewController(controller)
        }
        oldIndex = nil
        lastSelectedIndex = indexPath
        self.slideMenuController?.hideSideMenu()
    }
    
    /**
    VoiceRecogniser Delegate Method
    */
    /*func voiceRecogniser(voicerecogniser: VoiceRecogniser!, recognisedString string: String!) {
        print("Voice string: \(string)")
        if string == "Create" /* create request*/   {
            navigateTheScreen(createIndexPathForMenuItem(.NewRequest)!)
        }
        else if string == "Chat" /* chat */ {
            navigateTheScreen(createIndexPathForMenuItem(.NewChat)!)
        }
        else if string == "Mail" /* email */   {
            navigateTheScreen(createIndexPathForMenuItem(.NewEmail)!)
        }
        else if string == "Schedule" /* schedule */ {
            navigateTheScreen(createIndexPathForMenuItem(.NewSchedule)!)
        }
        else if string == "Call"    /* call */  {
            navigateTheScreen(createIndexPathForMenuItem(.NewCall)!)
        }
        else if string == "Logout"  /* Logout */    {
            logout()
        }
        
        //VoiceRecogniser.sharedInstance().stopListening()
    }*/

    /** 
    Motion Recognize
    */
    /*override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        dispatch_async(dispatch_get_main_queue()) {
            VoiceRecogniser.sharedInstance().loadSpeechKit()
        }
    }*/
    
    
    /**
    */
    func cancelClicked()    {
        /* Voice Recognition Calls */
        
        //VoiceRecogniser.sharedInstance().delegate = self
        //VoiceRecogniser.sharedInstance().usingStartingLanguageModel = 1

        //VoiceRecogniser.sharedInstance().stringArray = voiceCmdArray! as [AnyObject]
        //VoiceRecogniser.sharedInstance().delegate = self
        //VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "MenuClassOpenEarsDynamicLanguageModel"
        //VoiceRecogniser.sharedInstance().changePathToSuccessfullyGeneratedModel()
        
        //VoiceRecogniser.sharedInstance().startListening()
    }
    
    /**
    */
    func slideMenuTapped()  {
        //let voiceStrArray: NSArray? = NSArray(objects: "Create", "Logout", "Call", "Chat", "Schedule", "Mail")
        
        //VoiceRecogniser.sharedInstance().stringArray = voiceStrArray! as [AnyObject]
        //VoiceRecogniser.sharedInstance().delegate = self
        //VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "MenuClassOpenEarsDynamicLanguageModel"
        //VoiceRecogniser.sharedInstance().changePathToSuccessfullyGeneratedModel()
    }
    
    /**
    deinit 
    */
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension MenuViewController
{
    /**
    Create default content controller.

    - returns: the controller.
    */
    func createDefaultContentController() -> UIViewController {
        return createContentControllerAtIndex(defaultIndexPath())!
    }

    /**
    Create content controller at index.

    - parameter index: The index

    - returns: the controller.
    */
    func createContentControllerAtIndex(index: NSIndexPath) -> UIViewController? {
        return createContentControllerForItem(MenuViewController.sections[index.section].items[index.row])
    }

    /**
    Create controller for item.

    - parameter item: The item

    - returns: the controller.
    */
    func createContentControllerForItem(item: MenuItem) -> UIViewController? {
        if let menu = MenuViewController.menus[item] {
            let controller = storyboard?.instantiateViewControllerWithIdentifier(menu.controllerName)
            if let controller = controller as? DisabledViewController {
                controller.item = menu
            }
            if let controller = controller {
                return createNavigationControllerFor(controller)
            }
        }
        return nil
    }

    /**
    Create navigation controller for contrroller

    - parameter rootViewController: The root view controller

    - returns: the navigation controller
    */
    func createNavigationControllerFor(rootViewController: UIViewController) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: rootViewController)
        navigation.navigationBar.translucent = false
        return navigation
    }
}

extension MenuViewController : SlideMenuSideWidthDelegate
{
    /**
    the width of the side menu

    - returns: the width.
    */
    func slideMenuSideWidth() -> CGFloat {
        return tableView.bounds.width
    }
}

extension UIViewController {
    /**
    Add menu button
    */
    func addMenuButton() {
        let image = UIImage(named: "menu-icon")?.imageWithRenderingMode(.AlwaysOriginal)
        let menu = UIBarButtonItem(image: image, style: .Plain, target: self,
            action: "showSideMenuButtonTapped")
        navigationItem.leftBarButtonItem = menu
    }
}

extension MenuViewController : UITableViewDelegate {

    /**
    Height of header

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: the height.
    */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 72 : 39
    }

    /**
    View for header.

    - parameter tableView: The table view
    - parameter section:   The section

    - returns: the header view.
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataSource.getSectionViewOf(tableView, atIndex: section)
    }

    /**
    Deselected an item.

    - parameter tableView: The table view
    - parameter indexPath: The index path
    */
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        oldIndex = indexPath
    }

    /**
    Selected an item.

    - parameter tableView: The table view
    - parameter indexPath: The index path
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        /*if let controller = createContentControllerAtIndex(indexPath) {
            self.slideMenuController?.setContentViewController(controller)
        }
        lastSelectedIndex = indexPath
        oldIndex = nil
        self.slideMenuController?.hideSideMenu()*/ //Commented for voice recognization
        
        navigateTheScreen(indexPath)
    }
}

/**
* Programmatic menu item selection support
*
* @author Alexander Volkov
* @version 1.0
*/
extension MenuViewController {
    
    /**
    Set given menu item selected
    
    - parameter menuItem: the menu item
    */
    func setSelected(menuItem: MenuItem) {
        //Added by H146574
        if menuItem == .MyRequests  {
            //VoiceRecogniser.sharedInstance().delegate = nil
        }
        
        if let indexPath = createIndexPathForMenuItem(menuItem) {
            tableView.beginUpdates()
            if let old = lastSelectedIndex {
                tableView.deselectRowAtIndexPath(old, animated: false)
            }
            oldIndex = nil
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            tableView.endUpdates()
        }
    }
    
    /**
    Create NSIndexPath for given menu item
    
    - parameter menuItem: the menu item
    
    - returns: NSIndexPath
    */
    func createIndexPathForMenuItem(menuItem: MenuItem) -> NSIndexPath? {
        
        for i in 0..<MenuViewController.sections.count {
            let section = MenuViewController.sections[i]
            for j in 0..<section.items.count {
                let item = section.items[j]
                if item == menuItem {
                    return NSIndexPath(forRow: j, inSection: i)
                }
            }
        }
        return nil
    }
}
