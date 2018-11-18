//
// Created by Hanyuan Li on 3/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Timetable {
        static let defaultColours: [String: UIColor] = [
            "CAPA": UIColor(red: 20 / 255.0, green: 126 / 255.0, blue: 92 / 255.0, alpha: 1.0),
            "Careers/Library": UIColor(red: 223 / 255.0, green: 178 / 255.0, blue: 0.0, alpha: 1.0),
            "English": UIColor(red: 249 / 255.0, green: 1.0, blue: 0.0, alpha: 1.0),
            "Free Periods": UIColor.white,
            "HSIE": UIColor(red: 126 / 255.0, green: 132 / 255.0, blue: 60 / 255.0, alpha: 1.0),
            "IT": UIColor(red: 225 / 255.0, green: 0.0, blue: 157 / 255.0, alpha: 1.0),
            "Languages": UIColor(red: 1.0, green: 114 / 255.0, blue: 0.0, alpha: 1.0),
            "Lunch": UIColor.white,
            "Mathematics": UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            "PDHPE": UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
            "Recess": UIColor.white,
            "Roll Call": UIColor(red: 72 / 255.0, green: 0.0, blue: 64 / 255.0, alpha: 1.0),
            "Science": UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            "TAS": UIColor(red: 1.0, green: 84 / 255.0, blue: 1.0, alpha: 1.0),
            "Default": UIColor.white
        ]
        
        static let subjects = [
            "CAPA", "Careers/Library", "English", "Free Periods", "HSIE", "IT",
            "Languages", "Lunch", "Mathematics", "PDHPE", "Recess", "Roll Call",
            "Science", "TAS", "Default"
        ]
    }
}
