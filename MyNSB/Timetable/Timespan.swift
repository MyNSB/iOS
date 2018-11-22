//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON

class Timespan: NSObject, NSCoding {
    let name: String
    let start: Date
    let end: Date

    init(name: String, start: Date, end: Date) {
        self.name = name
        self.start = start
        self.end = end
    }
    
    init(name: String, time: String) {
        // Setting up calendar and date formatter
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        
        // Split "8:58am-9:50am" into ["8:58am", "9:50am"]
        let timeStrings = time.split(separator: "-")
        let timeframes = timeStrings.map { string -> Date in
            // Formats the string representation into a Date object
            let date = formatter.date(from: string.trimmingCharacters(in: .whitespaces))
            // Fetches hours, minutes, seconds from Date object (since they're the only
            // values that are set, the rest default to 0)
            let time = calendar.dateComponents([.hour, .minute, .second], from: date!)
            // Return the date today, but with the time described in `time`
            return calendar.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
        }
        
        self.name = name
        self.start = timeframes[0]
        self.end = timeframes[1]
    }

    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let start = aDecoder.decodeObject(forKey: "start") as! Date
        let end = aDecoder.decodeObject(forKey: "end") as! Date
        self.init(name: name, start: start, end: end)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.start, forKey: "start")
        aCoder.encode(self.end, forKey: "end")
    }
    
    func toPeriod(contents: JSON?) -> Period? {
        if contents == nil {
            return nil
        } else if self.name == "Recess" {
            return Recess(timespan: self)
        } else if self.name == "Lunch" {
            return Lunch(timespan: self)
        } else {
            return Period(contents: contents!, timespan: self)
        }
    }
}
