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
// TODO: add API calls upon opening app to fetch reminders into `sharedInstance`
//       and upon closing app to save reminders on remote server.
//       On disk storage will suffice whilst app is open
class ReminderList {
    static let sharedInstance = ReminderList()
    private let ITEMS_KEY = "reminderItems"
    
    func scheduleItem(_ item: Reminder) {
        let center = UNUserNotificationCenter.current()
        // remove previously existing notification, if any
        center.getPendingNotificationRequests(completionHandler: { (notificationRequests) in
            for request in notificationRequests {
                if request.identifier == item.UUID {
                    center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    break
                }
            }
        })
        // set the notification's contents
        let notification = UNMutableNotificationContent()
        notification.title = item.title
        notification.body = item.body ?? ""
        // create a trigger from the reminder's `due` property
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.due)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        // create a notification request with the reminder's UUID as identifier
        let request = UNNotificationRequest(identifier: item.UUID, content: notification, trigger: trigger)
        // register the request
        center.add(request) { (error) in
            if let error = error {
                print("error scheduling notification: \(error)")
            } else {
                print("registered \(notification.title)")
            }
        }
    }
    
    // adds item to the UserDefaults Dictionary, overwriting if it already exists
    func addItem(_ item: Reminder) {
        var reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? Dictionary()
        reminderDict[item.UUID] = ["title": item.title, "body": item.body ?? "", "dueDate": item.due, "repeats": item.repeats, "UUID": item.UUID]
        UserDefaults.standard.set(reminderDict, forKey: ITEMS_KEY)
    }
    
    func removeItem(_ item: Reminder) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { (notificationRequests) in
            for request in notificationRequests {
                if (request.identifier == item.UUID) {
                    center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    print("removed \(request.content.title)")
                    break
                }
            }
        })
        if var reminderDict = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) {
            reminderDict.removeValue(forKey: item.UUID)
            UserDefaults.standard.set(reminderDict, forKey: ITEMS_KEY)
        }
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
    
    // make sure all incomplete reminders are scheduled as notifications, called once in viewDidLoad
    // At this point I'm not sure whether shutdowns will discard notifications
    func refreshNotifications() {
        let center = UNUserNotificationCenter.current()
        // remove completed
        center.getPendingNotificationRequests(completionHandler: { (notificationRequests) in
            for reminder in ReminderList.sharedInstance.getReminders() {
                for request in notificationRequests {
                    if (reminder.UUID == request.identifier) {
                        break
                    }
                }
                print("\(reminder.title) was not found")
                // not found, schedule it now
                self.scheduleItem(reminder)
            }
        })
    }
}
