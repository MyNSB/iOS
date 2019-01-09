//
//  ReminderList.swift
//  test
//
//  Created by Plisp on 30/12/18.
//  Copyright © 2018 Plisp. All rights reserved.
//

import Foundation
import UserNotifications

/* This class manages the on disk storage of the reminders */
class ReminderList {
    static let sharedInstance = ReminderList()
    private let ITEMS_KEY = "reminderItems"
    
    func scheduleItem(_ item: Reminder) {
        let center = UNUserNotificationCenter.current()
        // remove previously existing notification
        center.getPendingNotificationRequests(completionHandler: { (notificationRequests) in
            for notification in notificationRequests {
                print("\(notification.content.title) is registered")
                // if an existing notification request matches that of the one to be scheduled
                if notification.identifier == item.UUID {
                    center.removePendingNotificationRequests(withIdentifiers: [item.UUID])
                    break
                }
            }
        })
        
        let notification = UNMutableNotificationContent()
        notification.title = item.title
        notification.body = item.body ?? ""
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.due)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: item.repeats)
        
        let request = UNNotificationRequest(identifier: item.UUID, content: notification, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("error scheduling notification: \(error)")
            } else {
                print("registered \(notification.title)")
            }
        }
    }
    
    // adds item to the UserDefaults Dictionary
    func addItem(_ item: Reminder) {
        var reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? Dictionary()
        reminderDict[item.UUID] = ["title": item.title, "body": item.body ?? "", "dueDate": item.due, "repeats": item.repeats, "UUID": item.UUID]
        UserDefaults.standard.set(reminderDict, forKey: ITEMS_KEY)
    }
    
    func removeItem(_ item: Reminder) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { (requests) in
            for i in requests {
                // FIXME: store UUID
                if (i.content.title == item.title) {
                    center.removePendingNotificationRequests(withIdentifiers: [i.content.title])
                    print("removed \(i.content.title)")
                    break
                }
            }
        })
        if var reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) {
            reminderDict.removeValue(forKey: item.UUID)
            UserDefaults.standard.set(reminderDict, forKey: ITEMS_KEY)
        }
    }
    
    func setItem(_ item: Reminder) {
        var reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY)
        // if reminderDict does not already exist this will throw
        reminderDict![item.UUID] = ["title": item.title, "body": item.body ?? "", "dueDate": item.due, "repeats": item.repeats, "UUID": item.UUID]
        UserDefaults.standard.set(reminderDict, forKey: ITEMS_KEY)
    }
    
    func getReminders() -> [Reminder] {
        let reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? [:]
        let items = Array(reminderDict.values)
        return items.map({
            let item = $0 as! [String:AnyObject]
            return Reminder(title: item["title"] as! String, body: item["body"] as? String, due: item["dueDate"] as! Date, repeats: item["repeats"] as! Bool, UUID: item["UUID"] as! String)
        }).sorted(by: { (remA, remB) -> Bool in
            (remA.due.compare(remB.due) == .orderedAscending)
        })
    }
}
