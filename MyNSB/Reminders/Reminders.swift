//
//  Reminders.swift
//  MyNSB
//
//  Created by Plisp on 6/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UserNotifications

class Reminder : NSObject, NSCoding {
    var title:  String
    var body:   String?
    var minute: Int?
    var hour:   Int?
    var day:    Int?
    var repeating:  Bool
    let identifier: UUID
    
    // Initialize calendar notification
    init(title: String, body: String?, minute: Int?, hour: Int?, day: Int?, repeating: Bool) {
        self.minute = minute
        self.hour = hour
        self.day = day
        self.title = title
        if let desc = body { self.body = desc }
        self.repeating = repeating
        self.identifier = UUID()
    }
    
    // decode/encode functions for archiving reminders
    @objc required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        body = aDecoder.decodeObject(forKey: "body") as? String
        minute = aDecoder.decodeObject(forKey: "minute") as? Int
        hour = aDecoder.decodeObject(forKey: "hour") as? Int
        day = aDecoder.decodeObject(forKey: "day") as? Int
        repeating = aDecoder.decodeBool(forKey: "repeating")
        identifier = UUID(uuidString: aDecoder.decodeObject(forKey: "uuid") as! String) ?? UUID()
    }
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
        aCoder.encode(minute, forKey: "minute")
        aCoder.encode(hour, forKey: "hour")
        aCoder.encode(day, forKey: "day")
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
        // sort out date
        var date = DateComponents()
        date.minute = self.minute
        date.hour = self.hour
        date.day = self.day
        // sort out content
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.body = self.body ?? ""
        content.sound = UNNotificationSound.default()
        // register the notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: self.repeating)
        let center = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(identifier: self.identifier.uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
}
