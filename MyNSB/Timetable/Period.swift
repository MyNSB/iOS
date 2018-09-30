//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

class Period {
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
}

class Recess: Period {
    init(start: Date, end: Date) {
        super.init(subject: Subject(name: "Recess"), teacher: nil, room: nil, start: start, end: end)
    }
}

class Lunch: Period {
    init(start: Date, end: Date) {
        super.init(subject: Subject(name: "Lunch"), teacher: nil, room: nil, start: start, end: end)
    }
}
