//
//  Timetable.swift
//  MyNSB
//
//  Created by Hanyuan Li on 31/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON

class Timetable: NSObject, NSCoding {
    let periods: [[Period]]
    
    init(json: JSON, bellTimes: BellTimes) {
        var periods = [[Period]](repeating: [], count: 10)
        let timetable = json.arrayValue
        
        for rawPeriod in timetable {
            let day = rawPeriod["day"].intValue - 1
            let timespan = bellTimes.timeOf(
                day: day,
                period: rawPeriod["period"].stringValue
            )
            
            let period = Period(contents: rawPeriod, timespan: timespan)
            periods[day].append(period)
        }
        
        self.periods = periods.map { day in
            day.sorted { $0.start < $1.start }
        }
    }
    
    func get(day: Int) -> [Period] {
        return periods[day]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.periods, forKey: "periods")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.periods = aDecoder.decodeObject(forKey: "periods") as! [[Period]]
    }
}
