//
//  FAQDetailsViewController.swift
//  Meli FFI Mobile Application
//
//  Created by Nikita Rodin on 8/6/15.
//  Modified by TCASSEMBLER on 16.08.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* FAQ details screen
*
* - Author: Nikita Rodin
* :version: 1.1
*
* changes:
* 1.1:
* - new API methods integration
*/
class FAQDetailsViewController: GAITrackedViewController {

    /// prefix for src value for an image in html
    let ENCODED_IMAGE_PREFIX = "data:image/jpeg;base64,"
    
    /// the maximum number of images in html
    let MAX_NUBMER_OF_IMAGES = 10
    
    // outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /// FAQ item
    var item: FAQItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "FAQ Details".localized
        self.addBackItem()
        
        
        loadData()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "FAQ Details: DocID=\(item.docId)" // Google Analytics screen name
    }
    
    /**
    Load details for related FAQ item and render in webView
    */
    func loadData() {
        loadingIndicator.startAnimating()
        ServerApi.sharedInstance.faqDetails(item, callback: { (json: JSON) -> () in
            
            
            let data = json.arrayValue[0]
            var html = data["RKMAnswer"].stringValue
            
            // Images
            var images = [(String, String)]()
            for i in 1...self.MAX_NUBMER_OF_IMAGES {
                let imagePrefix = "Image\(i)"
                if let (name, imageData) = self.getImageForPrefix(imagePrefix, json: data) {
                    images.append((name, imageData))
                }
            }
                
            // One more image (with "ImageX" prefix in keys). Required for demonstration.
            if let (name, imageData) = self.getImageForPrefix("ImageX", json: data) {
                images.append((name, imageData))
            }
            
            // Substitute images
            for (imageSrc, imageData) in images {
                let src = "\(self.ENCODED_IMAGE_PREFIX)\(imageData)"
                let changedHtml = self.replaceTagWithSrcData("src", tagValue: imageSrc, withSrcData: src, inHtml: html)
                if changedHtml == html { // if there is no "src" tag, them try to replace with "alt" tag
                    html = self.replaceTagWithSrcData("alt", tagValue: imageSrc, withSrcData: src, inHtml: html)
                }
                else {
                    html = changedHtml
                }
            }
            self.loadingIndicator.stopAnimating()
            self.showHtml(html)

        }) { (error, res) -> () in
            //error.showError()
            ErrorView.show("Error_NoFAQRecord".localized, inView: self.webView)
            self.loadingIndicator.stopAnimating()
        }
    }
    
    /**
    Substitutes encoded image into
    
    - parameter tag:      the html tag name
    - parameter tagValue: the value of the tag
    - parameter imageSrc: the encoded data
    - parameter html:     the original html
    
    - returns: changed html as a string
    */
    func replaceTagWithSrcData(tag: String, tagValue: String, withSrcData imageSrc: String,
        inHtml html: String) -> String {
        let string = "\(tag)=\"\(tagValue)\""
        return html.replace(string, withString: "style=\"width:100%;overflow: hidden;\" src=\"\(imageSrc)\"")
        //return html.replace(string, withString: "src=\"\(imageSrc)\"")
    }
    
    /**
    Extracts image name and data from given JSON and keys prefix
    
    - parameter prefix: the keys prefix
    - parameter json:   the json data
    
    - returns: image name and data or nil
    */
    func getImageForPrefix(prefix: String, json: JSON) -> (String, String)? {
        if let name = json["\(prefix)Name"].string,
            let imageData = json["\(prefix)Data"].string {
                if !name.isEmpty && !imageData.isEmpty {
                    return (name, imageData)
                }
        }
        return nil
    }
    
    /**
    Show given html string
    
    - parameter htmlString: the string
    */
    func showHtml(htmlString: String) {
        webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().resourceURL)
    }

}
