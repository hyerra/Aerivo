//
//  AppDelegate.swift
//  Aerivo MacOS
//
//  Created by Harish Yerra on 9/8/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Cocoa
import AerivoKit
import CloudCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if #available(macOS 10.14, *) { NSApplication.shared.registerForRemoteNotifications() }
        CloudCore.config = .aerivoSharedConfig
        CloudCore.enable(persistentContainer: DataController.shared.persistentContainer)
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        if CloudCore.isCloudCoreNotification(withUserInfo: userInfo) {
            CloudCore.fetchAndSave(using: userInfo, to: DataController.shared.persistentContainer, error: nil) { fetchResult in
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

