//
//  Reminder.swift
//  test
//
//  Created by Plisp on 28/12/18.
//  Copyright © 2018 Plisp. All rights reserved.
//

import Foundation

import SwiftyJSON

extension String {
    func parseReminderString() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD-MM-YYYY hh:mm"
        
        return formatter.date(from: self)!
    }
}

/* internally used by ReminderList.swift */
struct Reminder: Codable {
    let title: String
    let body:  String?
    let due:   Date
    let tags:  [String]
    let id:    String // stored as string
    
    init(json: JSON) {
        self.title = json["Headers"]["Subject"].stringValue
        self.body = json["Body"].stringValue
        self.due = json["DateTime"].stringValue.parseReminderString()
        self.tags = json["Tags"].arrayValue.map { $0.stringValue }
        self.id = String(json["ID"].intValue)
    }
    
    var overdue: Bool {
        return (Date().compare(self.due) == .orderedDescending)
    }
}
