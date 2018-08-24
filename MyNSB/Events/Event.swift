//
// Created by Hanyuan Li on 20/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Foundation

class Event {
    let name: String
    let start: Date
    let end: Date
    let location: String
    let organiser: String
    let shortDescription: String
    let longDescription: String
    let imageURL: String

    init(name: String, start: Date, end: Date, location: String, organiser: String, shortDescription: String, longDescription: String, imageURL: String) {
        self.name = name
        self.start = start
        self.end = end
        self.location = location
        self.organiser = organiser
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.imageURL = imageURL
    }
}
