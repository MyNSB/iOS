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
        
        for day in 0..<5 {
            let recess = Period(name: "Recess", timespan: bellTimes.timeOf(day: day, period: "Recess"))
            periods[day].append(recess)
            periods[day + 5].append(recess)
            
            if day != 2 {
                let lunch = Period(name: "Lunch", timespan: bellTimes.timeOf(day: day, period: "Lunch"))
                periods[day].append(lunch)
                periods[day + 5].append(lunch)
            }
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
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: self), forKey: "timetable")
    }
    
    static func fetch() -> Timetable? {
        let defaults = UserDefaults.standard
        return NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "timetable") as! Data) as! Timetable?
    }
    
    /// Checks if the user has their timetable stored locally.
    ///
    /// - Returns: A boolean that indicates whether the user has their timetable stored.
    static func isStored() -> Bool {
        return UserDefaults.standard.object(forKey: "timetable") != nil
    }
}
