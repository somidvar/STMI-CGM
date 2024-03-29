//
//  ExtensionDelegate.swift
//  WacthSTMI Extension
//
//  Created by Ryan Ramirez on 3/22/20.
//  Copyright © 2020 Ryan Ramirez. All rights reserved.
//

import WatchKit
import Firebase

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var HeartRateManager = heartRateManager()
    var motionManager = MotionManager()

    func applicationDidFinishLaunching() {
        print("We here")
        FirebaseApp.configure()
        /*
        self.HeartRateManager.AuthorizeHK() // Ask for Healthkit permission
        watchToPhone.activateSession() // Activate WCSession from our global variable
        self.motionManager.startQueuedMotionUpdates()
        self.motionManager.setupLocation()
        self.HeartRateManager.startWorkout()
         */
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (Timer) in
            //watchToPhone.sendSensorDataToPhone()
        })
        sensorData["altitude"] = 0.0
        sensorData["longitude"] = 0.0
        sensorData["latitude"] = 0.0
        sensorData["roll"] = 0.0
        sensorData["pitch"] = 0.0
        sensorData["yaw"] = 0.0
        sensorData["HR"] = 0.0
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
