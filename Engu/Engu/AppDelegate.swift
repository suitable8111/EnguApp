//
//  AppDelegate.swift
//  Engu
//
//  Created by Daeho on 2017. 2. 21..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initPlist()
        initCompletePlist()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func initPlist(){
        let fileManager = FileManager()
        //var error = NSError()
        var path = NSString()
        path = getPlistPath() as NSString
        print(path)
        let success = fileManager.fileExists(atPath: path as String)
        
        if(!success){
            let defalutPath = Bundle.main.resourcePath?.appending("/DataModel.plist")
            
            do {
                try fileManager.copyItem(atPath: defalutPath!, toPath: path as String)
            } catch _ {
            }
        }
        
    }
    func getPlistPath() -> String {
        var docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending("/DataModel.plist")
        return fullName
    }
    
    func initCompletePlist(){
        let fileManager = FileManager()
        //var error = NSError()
        var path = NSString()
        path = getCompletePlistPath() as NSString
        print(path)
        let success = fileManager.fileExists(atPath: path as String)
        
        if(!success){
            let defalutPath = Bundle.main.resourcePath?.appending("/CompleteModel.plist")
            
            do {
                try fileManager.copyItem(atPath: defalutPath!, toPath: path as String)
            } catch _ {
            }
        }
        
    }
    func getCompletePlistPath() -> String {
        var docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending("/CompleteModel.plist")
        return fullName
    }
}

