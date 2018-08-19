//
// Created by Hanyuan Li on 19/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation

struct Timespan {
    let name: String
    let start: Date
    let end: Date

    init(name: String, start: Date, end: Date) {
        self.name = name
        self.start = start
        self.end = end
    }
}
