//
//  AppDelegate.swift
//  Watpad
//
//  Created by THANOS on 9/30/20.
//  Copyright © 2020 XCode. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import SwiftyJSON
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
//    var clientID = "7c907fd193024bea84ceee7599ea17fc"
//    var authID = "NTczMzM4NTg3NjVhNGQ0ZGExMTQxZmFlNDIwNDQ0ODg6MmNlYWVjN2JjOTA0NDIyODk4YTJiMWRkZTUxMTA2YmY"
//    let SpotifyClientID = "7c907fd193024bea84ceee7599ea17fc"
//    let SpotifyRedirectURL = URL(string: "BOMU://returnAfterLogin")!
//    var accessToken = "BQDot8ZHhyXcqVoxA2TI0Tbm_cS7zyzcLtuX9PP-LxBbfkGupmIa5blJ9LDQryxzAqdlI8eZ7NfKLwF5lHQ"
//    var playerStatus = "pause"
//    var uri = ""
//    var initiation = false
    
//    lazy var configuration: SPTConfiguration = {
//        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
//        configuration.playURI = ""
////        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
////        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
//        return configuration
//    }()
//
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
//        appRemote.delegate = self
//        return appRemote
//    }()
//
//    lazy var sessionManager: SPTSessionManager = {
//        let manager = SPTSessionManager(configuration: configuration, delegate: self)
//        return manager
//    }()
//
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        print("connected")
//        self.appRemote.playerAPI?.delegate = self
//        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//            }
//        })
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//      print("disconnected")
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//      print("failed")
//    }
//
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        print("player state changed")
//        print("isPaused", playerState.isPaused)
//        if playerState.isPaused == true{
//            playerStatus = "pause"
//        }
//        else{
//            playerStatus = "play"
//        }
//        print("track.uri", playerState.track.uri)
//        print("track.name", playerState.track.name)
//        print("track.imageIdentifier", playerState.track.imageIdentifier)
//        print("track.artist.name", playerState.track.artist.name)
//        print("track.album.name", playerState.track.album.name)
//        print("track.isSaved", playerState.track.isSaved)
//        print("playbackSpeed", playerState.playbackSpeed)
//        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
//        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
//        print("playbackPosition", playerState.playbackPosition)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        self.appRemote.connectionParameters.accessToken = session.accessToken
//        self.appRemote.connect()
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print(error)
//        self.initiation == false
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession){
//        print(session)
//        self.initiation == false
//    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        if #available(iOS 13.0, *) {
            UIApplication.shared.statusBarStyle = .darkContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
        
//        getAccessToken()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.play), name: NSNotification.Name(rawValue: "PlaySPT"), object: nil)
        
        return true
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        
//        self.sessionManager.application(app, open: url, options: options)
//
//        let parameters = appRemote.authorizationParameters(from: url);
//        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//            appRemote.connectionParameters.accessToken = access_token
//            self.accessToken = access_token
//        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            print("Error desc")
//            // Show the error
//        }
        return true
    }
    
    // MARK: Sharing enable
    
    
    
//    func getAccessToken(){
//        let headers: HTTPHeaders = [
//            "Authorization": "Basic " + authID,
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//
//        let parameters = ["grant_type" : "client_credentials"]
//
//        AF.request("https://accounts.spotify.com/api/token", method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
//            switch response.result {
//            case .success(_):
//                let json = try? JSON(data: response.data!)
//                self.accessToken = json!["access_token"].string!
//                print("Access Token")
//                print(json)
//                print("<-------->")
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
//    @objc func play(){
//        if initiation == false{
//            let requestedScopes: SPTScope = [.appRemoteControl]
//            self.sessionManager.initiateSession(with: requestedScopes, options: .default)
//            initiation = true
//        }
//        else{
//
//        }
//        self.appRemote.connect()
//        self.appRemote.playerAPI?.delegate = self
//        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//            }
//        })
//        self.appRemote.playerAPI?.setRepeatMode(.track, callback: { (result, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        })
//
//        if uri == UserDefaults.standard.string(forKey:"CurrentURI")!{
//            if playerStatus == "play" {
//                print(playerStatus)
//                self.appRemote.playerAPI?.pause({ (result, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//                })
//            }
//            else{
//                print(playerStatus)
//                self.appRemote.playerAPI?.resume({ (result, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//                })
//            }
//        }
//        else{
//            print("New Song")
//            uri = UserDefaults.standard.string(forKey:"CurrentURI")!
//            print(uri)
////            self.appRemote.authorizeAndPlayURI(uri)
//            self.appRemote.playerAPI?.play(uri, callback: { (result, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            })
//        }
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
//        if self.appRemote.isConnected {
//            self.appRemote.disconnect()
//        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        if let _ = self.appRemote.connectionParameters.accessToken {
//            self.appRemote.connect()
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Watpad")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
