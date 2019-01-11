//
//  Events.swift
//  MyNSB
//
//  Created by Hanyuan Li on 9/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import Foundation

class Events {
    // Current calendar configuration
    private static var calendar = Calendar.current
    private let events: [Event]
    
    // Given a date `date`, returns that same date but at 00:00:00
    static func getDay(date: Date) -> Date {
        let currentComponents = Events.calendar.dateComponents([.year, .month, .day], from: date)
        return self.calendar.date(from: currentComponents)!
    }
    
    init(events: [Event]) {
        self.events = events
    }
    
    func dates() -> Set<Date> {
        var dates = Set<Date>()
        
        for event in self.events {
            var start = Events.getDay(date: event.start)
            let end = Events.getDay(date: event.end)
            
            while start <= end {
                dates.insert(start)
                start = Events.calendar.date(byAdding: .day, value: 1, to: start)!
            }
        }
        
        return dates
    }
    
    func filter(for date: Date) -> [Event] {
        return self.events.filter { event in
            let start = Events.getDay(date: event.start)
            let end = Events.getDay(date: event.end)
            return DateInterval(start: start, end: end).contains(date)
        }.sorted { first, second in
            first.start < second.start
        }
    }
}
