//
//  Timespan.swift
//  MyNSB
//
//  Created by Hanyuan Li on 1/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import Foundation

struct Timespan {
    let start: Date
    let end: Date
    
    init(time: String) {
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
        
        self.start = timeframes[0]
        self.end = timeframes[1]
    }
}
