//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by THANOS on 11/27/20.
//  Copyright © 2020 XCode. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    var sharedIdentifier = "group.BOMU.shareGroup"
    var fileType = ""
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        if self.textView.text.count == 0{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention", message: "Enter the name of the song and / or artist!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание", message: "Введите название песни и/или исполнителя!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
            return false
        }
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        
        if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem{
            for ele in item.attachments!{
                let itemProvider = ele
                if itemProvider.hasItemConformingToTypeIdentifier("public.mp3"){
                    fileType = "public.mp3"
                }
                if itemProvider.hasItemConformingToTypeIdentifier("public.m4a"){
                    fileType = "public.m4a"
                }
                print("File Type\(fileType)")
                
                if itemProvider.hasItemConformingToTypeIdentifier(fileType){
                    itemProvider.loadItem(forTypeIdentifier: fileType, options: nil, completionHandler: { (item, error) in
                        
                        var musicData: Data!
                        if let url = item as? URL{
                            musicData = try! Data(contentsOf: url)
                        }
                        
                        let dict: [String : Any] = ["musicData" :  musicData, "name" : self.contentText]
                        let savedata =  UserDefaults.init(suiteName: self.sharedIdentifier)
                        savedata?.set(dict, forKey: "music")
                        savedata?.synchronize()
                    })
                }
            }
        }
        
        
//        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
