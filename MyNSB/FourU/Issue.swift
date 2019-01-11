//
//  Issue.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Issue {
    let name: String
    let edition: String
    let coverimage: String
    
    init(dictionary: JSON) {
        self.name = dictionary["name"].stringValue
        self.edition = dictionary["editionmonth"].stringValue
        self.coverimage = dictionary["CoverImage"].stringValue
    }
    
}
