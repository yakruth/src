//
//  DisabledViewController.swift
//  Melli FFI Mobile Application
//
//  Created by mohamede1945 on 5/14/15.
//  Modified by Alexander Volkov on 08.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*!
Represents the disabled view controller class.

@author mohamede1945, Alexander Volkov
@version 1.0
*
* changes:
* 1.1:
* - Google Analytics support
*/
class DisabledViewController: GAITrackedViewController  /* VoiceRecogniserDelegate */ {
    
    /// Message to show
    let NOTIFY_MESSAGE = "Notify me when %% is enabled"
    
    /// Represents the image view.
    @IBOutlet weak var imageView: UIImageView!
    /// Represents the label.
    @IBOutlet weak var label: UILabel!
    /// Represents the button.
    @IBOutlet weak var button: UIButton!
  
    @IBOutlet weak var notifyMeLabel: UILabel!
    @IBOutlet weak var notifyMeSwitch: UISwitch!
    
    /// the disabled item.
    var item: MenuViewController.Menu?

    let _eid = AuthenticationUtil.getUserInfo()!.username
    
    /**
    View will appear.
    
    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Disabled Screen"
        
        //VoiceRecogniser.sharedInstance().startListening()
    }
    
    /**
    view did loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "notImplementedFeature".localized
        addMenuButton()
        if let item = item {
            title = item.name
            imageView.image = UIImage(named: item.imageName + "-big")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        syncSwitch()
        
        //VoiceRecogniser.sharedInstance().stopListening()
    }
    
    /**
    Request if user is subscribed to the notifications
    */
    func syncSwitch() {
        if let contentLabel = item?.item.getDisabledContentLabel() {
            showNotifyMeOption(true)
            notifyMeLabel.text = NOTIFY_MESSAGE.replace("%%", withString: item!.name)
            notifyMeSwitch.enabled = false
            
            ServerApi.sharedInstance.getEnabledSubscriptions(_eid, callback: { (json: JSON) -> () in
                let enabledAlerts: [String] = json.arrayValue.map({$0["ContentLabel"].stringValue})
                
                self.notifyMeSwitch.on = enabledAlerts.contains(contentLabel)
                self.notifyMeSwitch.enabled = true
                
            }, errorCallback: { (error, res) -> () in
                self.notifyMeSwitch.enabled = true
               // error.showError()
            })
        }
        else {
            showNotifyMeOption(false)
        }
    }
    
    func showNotifyMeOption(show: Bool) {
        notifyMeLabel.hidden = !show
        notifyMeSwitch.hidden = !show
    }
    
    @IBAction func notifySwitchAction(sender: UISwitch) {
        if let contentLabel = item?.item.getDisabledContentLabel() {
            notifyMeSwitch.enabled = false
            ServerApi.sharedInstance.cachedNewsItems = nil
            ServerApi.sharedInstance.setSubscriptions(_eid,
                contentLabel: contentLabel,
                subscriptionFlag: sender.on ? "Yes" : "No",
                callback: { (json) -> () in
                    self.notifyMeSwitch.enabled = true
                    
            }, errorCallback: { (error, res) -> () in
                error.showError()
                self.notifyMeSwitch.enabled = false
            })
        }
    }
    
    /**
    View did appear
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Voice Recognition Calls */
        
//        let voiceStrArray: NSArray? = NSArray(objects: "Back")
//        VoiceRecogniser.sharedInstance().stringArray = voiceStrArray! as [AnyObject]
//        VoiceRecogniser.sharedInstance().delegate = self
//        VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "DisabledViewClassOpenEarsDynamicLanguageModel"
//        VoiceRecogniser.sharedInstance().changePathToSuccessfullyGeneratedModel()
//        
//        VoiceRecogniser.sharedInstance().startListening()
    }
    
    /**
    VoiceRecogniser Delegate Method
    */
    /*func voiceRecogniser(voicerecogniser: VoiceRecogniser!, recognisedString string: String!) {
        print("Voice string: \(string)")
        if string == "Back" /* create request*/   {
            showSideMenuButtonTapped()
        }
    }*/

}
