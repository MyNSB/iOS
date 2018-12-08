//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON

class Period: NSObject, NSCoding {
    let subject: Subject
    let teacher: String?
    let room: String?
    let start: Date
    let end: Date
    
    // Initialise function for subjects without teachers or rooms (i.e. recess,
    // lunch, free periods)
    init(name: String, timespan: Timespan) {
        self.subject = Subject(name: name)
        self.teacher = nil
        self.room = nil
        self.start = timespan.start
        self.end = timespan.end
    }
    
    // Normal initialisation functions
    init(contents: JSON, timespan: Timespan) {
        self.subject = Subject(name: contents["class"].stringValue)
        self.teacher = contents["teacher"].stringValue
        self.room = contents["room"].stringValue
        self.start = timespan.start
        self.end = timespan.end
    }

    // Decodes an NSObject back into a Period
    required init(coder aDecoder: NSCoder) {
        self.subject = aDecoder.decodeObject(forKey: "subject") as! Subject
        self.teacher = aDecoder.decodeObject(forKey: "teacher") as! String?
        self.room = aDecoder.decodeObject(forKey: "room") as! String?
        self.start = aDecoder.decodeObject(forKey: "start") as! Date
        self.end = aDecoder.decodeObject(forKey: "end") as! Date
    }

    // Encodes a Period into an NSObject
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.subject, forKey: "subject")
        aCoder.encode(self.teacher, forKey: "teacher")
        aCoder.encode(self.room, forKey: "room")
        aCoder.encode(self.start, forKey: "start")
        aCoder.encode(self.end, forKey: "end")
    }
}
