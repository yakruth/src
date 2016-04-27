//
//  PhoneSupportViewController.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
Represents the phone support view controller class.

@author mohamede1945

@version 1.0
*/
class PhoneSupportViewController: GAITrackedViewController  {

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the data source.
    var dataSource: ArraySectionedDataSource<PhoneSupportCategory, SupportTableHeaderView, PhoneSupport, SupportTableViewCell>!

    let deskInteractor = ServiceDeskDetailsInteractor()
    
    /**
    View did load.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PhoneSupport".localized
        addMenuButton()

        tableView.registerClass(SupportTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")

        setupTable([])
        loadData()
        //VoiceRecogniser.sharedInstance().stopListening()
    }
    
    func setupTable(data: [PhoneSupportCategory]) {
        dataSource = ArraySectionedDataSource(sections: data,
            cellReuseIdentifier: "cell",
            sectionReuseIdentifier: "header",
            configureSectionClosure: { (header, section, _) -> Void in
                
                header.label.text = section.name
                
            }, configureCellClosure: { (cell, item, _) -> Void in
                cell.configureFor(item)
        })
        tableView.dataSource = dataSource.proxy
    }

    func loadData() {
        let loginView = LoadingView(message: "Loading".localized, parentView: self.view)
        loginView.show()

        deskInteractor.retrieveServiceDeskDetails(success: { [weak self] (json: JSON, country: String?) -> () in

            self?.setupTable(PhoneSupportCategory.fromJson(json, countryName: country))
            self?.tableView.reloadData()
            loginView.terminate()

            }) { [weak self] (error) -> () in
                self?.showAlert(error.localizedDescription)
                
                loginView.terminate()
        }
    }

    /**
    view will appear.

    - parameter animated: The animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "Phone Support Screen" // Google Analytics screen name
        
        //VoiceRecogniser.sharedInstance().startListening()
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
//        VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "PhoneSupportClassOpenEarsDynamicLanguageModel"
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


extension PhoneSupportViewController : UITableViewDelegate
{
    /**
    Table view view for header in section.

    - parameter tableView: The table view parameter.
    - parameter section:   The section parameter.

    - returns: The header view.
    */
//  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return dataSource.getSectionViewOf(tableView, atIndex: section)
//    }

    /**
    Table view did select row at index path.

    - parameter tableView: The table view parameter.
    - parameter indexPath: The index path parameter.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let phone = dataSource.itemAtIndexPath(indexPath)

        if let numberURL = NSURL(string: "tel://" + phone.phoneNumber()) {
            UIApplication.sharedApplication().openURL(numberURL)
        }
    }
}
