//
//  AppDelegate.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private static let defaults = UserDefaults.standard
    
    private static var isFirstLaunch: Bool {
        return !AppDelegate.defaults.bool(forKey: "launchedFlag")
    }
    
    @objc private func requestNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (success, error) in
            if success {
                print("Notifications enabled")
            } else {
                print("Notification permissions request failed with error: \(error!)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // If the user hasn't launched the app before:
        if AppDelegate.isFirstLaunch {
            // Add default constants
            
            AppDelegate.defaults.set(true, forKey: "timetableUpdatesFlag")
            // Add default constant for colours (based off of NSB intranet colours on timetables)
            AppDelegate.defaults.set(NSKeyedArchiver.archivedData(withRootObject: Constants.Timetable.defaultColours), forKey: "timetableColours")
            
            AppDelegate.defaults.set([String](), forKey: "timetableNotifs")
            
            // Set up notifications (or not)
            self.requestNotifications()
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings { settings in
                if settings.alertSetting == UNNotificationSetting.enabled {
                    AppDelegate.defaults.set(true, forKey: "notificationsEnabledFlag")
                } else {
                    AppDelegate.defaults.set(false, forKey: "notificationsEnabledFlag")
                }
            }
            
            // We've loaded all the default settings already, set self.isFirstLaunch to `false`
            AppDelegate.defaults.set(true, forKey: "launchedFlag")
        }
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reminderListShouldRefresh"), object: self)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

