//
//  BellTimes.swift
//  MyNSB
//
//  Created by Hanyuan Li on 1/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON

class BellTimes {
    let times: [String: [String: Timespan]]
    
    init(json: JSON) {
        let days = json.dictionaryValue
        
        self.times = days.mapValues { day in
            let timespans = day.dictionaryValue
            return timespans.mapValues { Timespan(time: $0.stringValue) }
        }
    }
    
    func timeOf(day: Int, period: String) -> Timespan {
        let weekdayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let weekday = weekdayNames[day % 5]
        
        return self.times[weekday]![period]!
    }
}
