//
// Created by Hanyuan Li on 2/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct Subject {
    let group: String
    let shortName: String
    let longName: String

    private static func find(name: String) -> (String, String) {
        if name == "Recess" || name == "Lunch" {
            return (name, name)
        }

        if let path = Bundle.main.path(forResource: "subject_list", ofType: "json") {
            do {
                let regex = try NSRegularExpression(pattern: "\\d+[A-Z]+\\d+")
                let matchName = regex.stringByReplacingMatches(in: name, range: NSRange(location: 0, length: name.count), withTemplate: "$2$3")

                let string = try String(contentsOfFile: path)
                let json = JSON(parseJSON: string).dictionaryValue

                for (group, subjects) in json {
                    let subjectJSON = subjects.dictionaryValue

                    for (key, value) in subjectJSON {
                        if matchName.range(of: key) != nil {
                            return (group, value.stringValue)
                        }
                    }
                }

                return ("Default", name)
            } catch {
                return ("Default", name)
            }
        }

        return ("Default", name)
    }

    init(name: String) {
        self.shortName = name
        (self.group, self.longName) = Subject.find(name: name)
    }

    static func textColourIsWhite(colour: UIColor) -> Bool {
        let localColour = CIColor(color: colour)
        let luminance = 0.299 * localColour.red + 0.587 * localColour.green + 0.114 * localColour.blue

        return (luminance <= 0.5)
    }
}