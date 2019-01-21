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
    let description: String
    let imageURL: String
    let link: String
    
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.description = json["Desc"].stringValue
        self.imageURL = json["ImageUrl"].stringValue
        self.link = json["Link"].stringValue
    }
}
