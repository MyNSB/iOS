//
//  Reminders.swift
//  MyNSB
//
//  Created by Plisp on 6/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UserNotifications

/* this class encapsulates the process of creating a notification given a date
 TODO: derive countdown and 'set date' reminders from this */

class Reminder : NSObject, NSCoding {
    var notif : UNMutableNotificationContent
    var date : DateComponents
    var repeating : Bool
    let identifier: UUID
    
    // Initialize calendar notification
    init(title: String, body: String?, minute: Int?, hour: Int?, day: Int?, repeating: Bool) {
        // date
        var date = DateComponents()
        date.minute = minute
        date.hour = hour
        date.day = day
        self.date = date
        // notification
        let notif = UNMutableNotificationContent()
        notif.title = title
        notif.body = body ?? ""
        self.notif = notif
        //
        self.repeating = repeating
        self.identifier = UUID()
    }
    
    // decode/encode functions for archiving reminders
    @objc required init?(coder aDecoder: NSCoder) {
        notif = aDecoder.decodeObject(forKey: "notif") as! UNMutableNotificationContent
        date = aDecoder.decodeObject(forKey: "date") as! DateComponents
        repeating = aDecoder.decodeBool(forKey: "repeating")
        identifier = UUID(uuidString: aDecoder.decodeObject(forKey: "uuid") as! String) ?? UUID()
    }
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(notif, forKey: "notif")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(repeating, forKey: "repeating")
        aCoder.encode(identifier.uuidString, forKey: "uuid")
    }
    
    // unecessarily verbose delegating constructor
    convenience override init() {
        let date = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        let day = calendar.component(.day, from: date)
        
        self.init(title: "New Reminder", body: "", minute: minute, hour: hour, day: day, repeating: false)
    }
    
    // register local notification
    func registerLocal() {
        let date = self.date
        //self.notif.sound = UNNotificationSound.default() // change later
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: repeating)
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: notif, trigger: trigger)
        // register notification
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
}
