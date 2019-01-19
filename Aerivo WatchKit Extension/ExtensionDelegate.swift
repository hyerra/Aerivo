//
//  ExtensionDelegate.swift
//  Aerivo WatchKit Extension
//
//  Created by Harish Yerra on 8/12/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import WatchKit
import AerivoKit
import CloudCore

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        CloudCore.configureForAerivo()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        CloudCore.enable(persistentContainer: DataController.shared.persistentContainer)
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                if #available(watchOS 5.0, *) {
                    if let relevantShortcutTask = task as? WKRelevantShortcutRefreshBackgroundTask {
                        // Be sure to complete the relevant-shortcut task once you're done.
                        relevantShortcutTask.setTaskCompletedWithSnapshot(false)
                    } else if let intentDidRunTask = task as? WKIntentDidRunRefreshBackgroundTask {
                        // Be sure to complete the intent-did-run task once you're done.
                        intentDidRunTask.setTaskCompletedWithSnapshot(false)
                    }
                }
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // MARK: - User Activity
    
    func handle(_ userActivity: NSUserActivity) {
        let userActivityManager = UserActivityManager(visibleInterfaceController: WKExtension.shared().visibleInterfaceController)
        if #available(watchOS 5.0, *), let intent = userActivity.interaction?.intent as? AirQualityIntent {
            userActivityManager.handle(airQualityIntent: intent)
        } else {
            userActivityManager.handle(userActivity: userActivity)
        }
    }
}
