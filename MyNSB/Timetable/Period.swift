//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

class Period: NSObject, NSCoding {
    let subject: Subject
    let teacher: String?
    let room: String?
    let start: Date
    let end: Date

    init(subject: Subject, teacher: String?, room: String?, start: Date, end: Date) {
        self.subject = subject
        self.teacher = teacher
        self.room = room
        self.start = start
        self.end = end
    }

    required init(coder aDecoder: NSCoder) {
        self.subject = aDecoder.decodeObject(forKey: "subject") as! Subject
        self.teacher = aDecoder.decodeObject(forKey: "teacher") as! String?
        self.room = aDecoder.decodeObject(forKey: "room") as! String?
        self.start = aDecoder.decodeObject(forKey: "start") as! Date
        self.end = aDecoder.decodeObject(forKey: "end") as! Date
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.subject, forKey: "subject")
        aCoder.encode(self.teacher, forKey: "teacher")
        aCoder.encode(self.room, forKey: "room")
        aCoder.encode(self.start, forKey: "start")
        aCoder.encode(self.end, forKey: "end")
    }
}

class Recess: Period {
    init(start: Date, end: Date) {
        super.init(subject: Subject(name: "Recess"), teacher: nil, room: nil, start: start, end: end)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Lunch: Period {
    init(start: Date, end: Date) {
        super.init(subject: Subject(name: "Lunch"), teacher: nil, room: nil, start: start, end: end)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
