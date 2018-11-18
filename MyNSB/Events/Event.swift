//
// Created by Hanyuan Li on 20/7/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class Event {
    let name: String
    let start: Date
    let end: Date
    let location: String
    let organiser: String
    let shortDescription: String
    let longDescription: String
    let imageURL: String
    
    private func parseDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return formatter.date(from: string)!
    }
    
    init(contents: JSON) {
        self.name = contents["EventName"].stringValue
        self.start = self.parseDate(from: contents["EventStart"].stringValue)
        self.end = self.parseDate(from: contents["EventEnd"].stringValue)
        self.location = contents["EventLocation"].stringValue
        self.organiser = contents["EventOrganiser"].stringValue
        self.shortDescription = contents["EventShortDesc"].stringValue
        self.longDescription = contents["EventLongDesc"].stringValue
        self.imageURL = contents["EventPictureURL"].stringValue
    }
}
