//
//  ReminderAPI.swift
//  MyNSB
//
//  Created by Hanyuan Li on 21/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import Foundation

import AwaitKit
import PromiseKit

extension Date {
    func parseReminderDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD-MM-YYYY hh:mm"
        
        return formatter.string(from: self)
    }
}

class ReminderAPI {
    static func create(subject: String, body: String, tags: [String], date: Date) -> Promise<Void> {
        return async {
            try await(
                MyNSBRequest.post(
                    path: "/reminders/create",
                    parameters: [
                        "Body": body,
                        "Subject": subject,
                        "Tags": tags,
                        "Date": date.parseReminderDate()
                    ]
                )
            )
        }
    }
    
    static func delete(id: String) -> Promise<Void> {
        return async {
            try await(MyNSBRequest.post(
                path: "/reminders/delete",
                parameters: ["Reminder_ID": id]
            ))
        }
    }
    
    static func get() -> Promise<[Reminder]> {
        return async {
            let body = try await(MyNSBRequest.get(path: "/reminders/get")).arrayValue
            return body.map { Reminder(json: $0) }
        }
    }
}
