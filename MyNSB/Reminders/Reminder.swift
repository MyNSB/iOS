//
//  Reminder.swift
//  test
//
//  Created by Plisp on 28/12/18.
//  Copyright © 2018 Plisp. All rights reserved.
//

import Foundation

/* internally used by ReminderList.swift */
struct Reminder: Codable {
    var title:   String
    var body:    String?
    var due:     Date
    var UUID:    String // stored as string
    var repeats: Bool
    
    init(title: String, body: String?, due: Date, repeats: Bool, UUID: String){
        self.title = title
        self.body = body
        self.due = due
        self.repeats = repeats
        self.UUID = UUID
    }
    
    var overdue: Bool {
        return (Date().compare(self.due) == .orderedDescending)
    }
}
