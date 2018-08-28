//
//  AppDelegate.swift
//  Aerivo
//
//  Created by Harish Yerra on 7/1/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import UIKit
import AerivoKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        application.registerForRemoteNotifications()
        CloudCore.config = .aerivoSharedConfig
        CloudCore.enable(persistentContainer: DataController.shared.persistentContainer)
        
        let quickActionsManager = QuickActionsManager(window: nil)
        application.shortcutItems = quickActionsManager.dynamicShortcutItems()
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
        
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CloudCore.isCloudCoreNotification(withUserInfo: userInfo) {
            CloudCore.fetchAndSave(using: userInfo, to: DataController.shared.persistentContainer, error: nil) { fetchResult in
                completionHandler(fetchResult.uiBackgroundFetchResult)
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - User Activity
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if #available(iOS 12.0, *), let intent = userActivity.interaction?.intent as? AirQualityIntent {
            let userActivityManager = UserActivityManager(window: window)
            return userActivityManager.handle(airQualityIntent: intent)
        } else {
            let userActivityManager = UserActivityManager(window: window)
            return userActivityManager.handle(userActivity: userActivity)
        }
    }
    
    // MARK: - Quick Actions
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let quickActionsManager = QuickActionsManager(window: window)
        let handledShortcutItem = quickActionsManager.handle(shortcutItem: shortcutItem)
        completionHandler(handledShortcutItem)
    }
}
