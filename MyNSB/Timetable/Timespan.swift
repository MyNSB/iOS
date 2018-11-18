//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

class Timespan: NSObject, NSCoding {
    let name: String
    let start: Date
    let end: Date

    init(name: String, start: Date, end: Date) {
        self.name = name
        self.start = start
        self.end = end
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
}
