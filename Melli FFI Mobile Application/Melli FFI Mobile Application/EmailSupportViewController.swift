//
//  EmailSupportViewController.swift
//  Meli FFI Mobile Application
//
//  Created by mohamede1945 on 6/15/15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import MessageUI

/**
Represents the email support view controller class.

@author mohamede1945

@version 1.0
*/
class EmailSupportViewController: GAITrackedViewController /* VoiceRecogniserDelegate */ {

    /// Represents the table view.
    @IBOutlet weak var tableView: UITableView!

    /// Represents the data source.
    var dataSource: ArraySectionedDataSource<EmailSupportCategory, SupportTableHeaderView, EmailSupport, SupportTableViewCell>!

    let deskInteractor = ServiceDeskDetailsInteractor()

    /**
    View did load.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EmailSupport".localized
        addMenuButton()

        tableView.registerClass(SupportTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")

        setupTable([])
        loadData()
        
        //VoiceRecogniser.sharedInstance().stopListening()
    }
    
    func setupTable(data: [EmailSupportCategory]) {
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

            self?.setupTable(EmailSupportCategory.fromJson(json, countryName: country))
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
        self.screenName = "Email Support Screen" // Google Analytics screen name
        
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
//        VoiceRecogniser.sharedInstance().pathToDynamicallyGeneratedLanguageModel = "EmailSupportClassOpenEarsDynamicLanguageModel"
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


extension EmailSupportViewController : UITableViewDelegate
{
    /**
    Table view view for header in section.

    - parameter tableView: The table view parameter.
    - parameter section:   The section parameter.

    - returns: the header view.
    */
/*    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataSource.getSectionViewOf(tableView, atIndex: section)
    }
*/
    /**
    Table view did select row at index path.

    - parameter tableView: The table view parameter.
    - parameter indexPath: The index path parameter.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let email = dataSource.itemAtIndexPath(indexPath)

        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject(email.subject)
        picker.setToRecipients([email.email])
        presentViewController(picker, animated: true, completion: nil)
    }
}

extension EmailSupportViewController : MFMailComposeViewControllerDelegate {

    /**
    Mail compose controller did finish with result and error.

    - parameter controller: The controller parameter.
    - parameter result:     The result parameter.
    - parameter error:      The error parameter.
    */
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
